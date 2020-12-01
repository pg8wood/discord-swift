//
//  DiscordGateway.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 11/24/20.
//

import Foundation
import Combine

class DiscordGateway: WebSocketGateway {
    lazy var eventPublisher = eventSubject.eraseToAnyPublisher()
    
    let session: URLSession
    let discordAPI: APIClient
    
    private var cancellables = Set<AnyCancellable>()
    private var webSocketTask: URLSessionWebSocketTask?
    private var eventSubject = PassthroughSubject<Event, Never>()
    
    /// Used for heartbeats and resuming sessions.
    ///
    /// https://discord.com/developers/docs/topics/gateway#payloads-gateway-payload-structure
    private var mostRecentSequenceNumber: Int?
    private var heartbeatTimer: Timer?
    
    init(session: URLSession, discordAPI: DiscordAPI) {
        self.session = session
        self.discordAPI = discordAPI
    }
    
    func send(command: Command) {
        guard let webSocketTask = webSocketTask else {
            print("WSS tried to idenfity but no task exists!")
            return
        }
        
        let message = GatewayMessage(opCode: command.opCode, payload: .command(command))
        
        do {
            let data = try JSONEncoder().encode(message)
            
            print("WSS sending message with code: \(message.opCode)")
            webSocketTask.send(URLSessionWebSocketTask.Message.data(data)) { error in
                if let error = error {
                    print("WSS error: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Error encoding GatewayMessage: \(error.localizedDescription)")
        }
    }
    
    /// Asks the Discord HTTP API for a Gateway URL, opens a web socket to that URL,  sends an identification payload to login.
    /// Keeps the web socket connection open and begins listening for messages if the connection succeeds.
    func connect() -> AnyPublisher<ReadyPayload, GatewayError> {
        discordAPI.get(GetGatewayRequest())
            .mapError { error -> GatewayError in
                .http(error)
            }
            .flatMap { gateway in
                self.openWSSConnection(at: gateway.url)
            }
            .handleEvents(receiveCompletion: { completion in
                guard case .finished = completion else { return }
                // A valid finish of this publisher indicates we are ready to send and receive messages over the web socket
                self.listenForMessages()
            })
            .eraseToAnyPublisher()
    }
    
    private func openWSSConnection(at url: URL) -> AnyPublisher<ReadyPayload, GatewayError> {
        Deferred {
            Future { [weak self] fulfill in
                guard let self = self else { return }
                
                let task = self.session.webSocketTask(with: url)
                self.webSocketTask = task
                
                task.receive { [weak self] result in
                    guard let self = self else { return }
                    
                    switch result {
                    case .success(let message):
                        let messageData: Data?
                        
                        switch message {
                        case .data(let data):
                            messageData = data
                        case .string(let string):
                            messageData = string.data(using: .utf8)
                        @unknown default:
                            print("Encountered a new web socket data type!")
                            fatalError()
                        }
                        
                        guard let incomingMessage = self.decodeAndAcceptMessage(from: messageData) else {
                            fulfill(.failure(.decodingFailed))
                            return
                        }
                        
                        guard case .event(.hello(let helloResponse)) = incomingMessage.payload else {
                            fulfill(.failure(.initialConnectionFailed))
                            return
                        }
                        
                        self.beginHeartbeat(millisecondInterval: helloResponse.heartbeatInterval)
                        
                        self.identify()
                            .sink(receiveCompletion: { completion in
                                guard case .finished = completion else {
                                    fulfill(.failure(.initialConnectionFailed))
                                    return
                                }
                            }, receiveValue: { readyPayload in
                                fulfill(.success(readyPayload))
                            })
                            .store(in: &self.cancellables)
                    case .failure(let error):
                        fulfill(.failure(.webSocket(error)))
                    }
                }
                
                task.resume()
            }
        }
        .eraseToAnyPublisher()
    }
    
    /// Decodes a message sent from the Gateway, notifies downstream Publishers of the event, and stores the event's sequence number.
    @discardableResult
    private func decodeAndAcceptMessage(from data: Data?) -> GatewayMessage? {
        guard let data = data else {
            return nil
        }
        
        do {
            let message = try JSONDecoder().decode(GatewayMessage.self, from: data)
            print(#"Got message code "\#(message.opCode)" \#(message.eventType != nil ? "| event name: \(message.eventType!)" : "")"#)
            
            if let sequenceNumber = message.sequenceNumber {
                self.mostRecentSequenceNumber = sequenceNumber
            }
            
            if case .event(let event) = message.payload {
                self.eventSubject.send(event)
            }
            
            return message
        } catch {
            print("error decoding gateway message")
            return nil
        }
    }
    
    /// Step 2 of connecting to the Discord Gateway and maintaining the connection
    /// https://discord.com/developers/docs/topics/gateway#heartbeating
    private func beginHeartbeat(millisecondInterval: Double) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.heartbeatTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(millisecondInterval / 1000), repeats: true) { _ in
                // TODO: invalidate when the connection is dropped. Also send heartbeats when the gateway requests one. See https://discord.com/developers/docs/topics/gateway#heartbeating
                // TODO: If we don't get back a HEARTBEAT ACK in-between heartbeats, close the connection and reconnect. See https://discord.com/developers/docs/topics/gateway#heartbeating-example-gateway-heartbeat-ack
                
                let heartbeatCommand = HeartbeatCommand(mostRecentSequenceNumber: self.mostRecentSequenceNumber)
                self.send(command: .heartbeat(heartbeatCommand))
            }
        } 
    }
    
    /// Step 3 (final)  of connecting to the Discord Gateway
    /// https://discord.com/developers/docs/topics/gateway#identifying
    private func identify() -> AnyPublisher<ReadyPayload, GatewayError> {
        let payload = IdentifyCommand(token: Secrets.discordToken)
        send(command: .identity(payload))
        
        return
            Deferred {
                Future { [weak self] fulfill in
                    guard let self = self else { return }
                    
                    self.webSocketTask?.receive { result in
                        switch result {
                        case .success(let message):
                            let messageData: Data?
                            
                            switch message {
                            case .data(let data):
                                messageData = data
                            case .string(let string):
                                messageData = string.data(using: .utf8)
                            @unknown default:
                                print("Encountered a new web socket data type!")
                                fatalError()
                            }
                            
                            guard let incomingMessage = self.decodeAndAcceptMessage(from: messageData) else {
                                fulfill(.failure(.decodingFailed))
                                return
                            }
                            
                            guard case .event(.dispatch(.ready(let readyPayload))) = incomingMessage.payload else {
                                fulfill(.failure(.initialConnectionFailed))
                                return
                            }
                            
                            fulfill(.success(readyPayload))
                        case .failure(let error):
                            fulfill(.failure(.webSocket(error)))
                        }
                    }
                }
            }
            .eraseToAnyPublisher()
    }
    
    /// Call this after authenticating to keep listening for new incoming messages.
    private func listenForMessages() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            
            let messageData: Data?
            switch result {
            case .success(let message):
                defer {
                    // Foundation only lets this closure run once, so we must re-register it. 🤷‍♀️
                    self.listenForMessages()
                }
                
                switch message {
                case .data(let data):
                   messageData = data
                case .string(let string):
                    let data = string.data(using: .utf8)
                    messageData = data
                @unknown default:
                    print("got unknown message type!")
                    fatalError()
                }
                
                self.decodeAndAcceptMessage(from: messageData)
            case .failure(let error):
                print("Failed to receive web socket message: \(error)")
            }
        }
    }
}

private extension Data {
    var prettyPrintedJSONString: NSString? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
        
        return prettyPrintedString
    }
}
