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
    private var eventSubject = PassthroughSubject<DiscordEvent, Never>()
    
    init(session: URLSession, discordAPI: DiscordAPI) {
        self.session = session
        self.discordAPI = discordAPI
    }
    
    func send(_ message: GatewayMessage) {
        guard let webSocketTask = webSocketTask else {
            print("WSS tried to idenfity but no task exists!")
            return
        }
        
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
        // Step 1 of connecting to Discord Gateway: https://discord.com/developers/docs/topics/gateway#connecting
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
                        
                        guard let incomingMessage = self.decodeMessage(from: messageData) else {
                            fulfill(.failure(.decodingFailed))
                            return
                        }
                        
                        guard case .hello(let helloResponse) = incomingMessage.payload else {
                            fulfill(.failure(.initialConnectionFailed))
                            return
                        }
                        
                        self.beginHeartbeat(interval: helloResponse.heartbeatInterval)
                        
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
    
    private func decodeMessage(from data: Data?) -> GatewayMessage? {
        guard let data = data else {
            return nil
        }
        
        do {
            let message = try JSONDecoder().decode(GatewayMessage.self, from: data)
            print(#"Got message code "\#(message.opCode)" \#(message.eventType != nil ? "| event name: \(message.eventType!)" : "")"#)
            return message
        } catch {
            print("error decoding message: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// Step 2 of connecting to the Discord Gateway and maintaining the connection
    /// https://discord.com/developers/docs/topics/gateway#heartbeating
    private func beginHeartbeat(interval: Int) {
        // TODO: necessary for the discord spec to actually send these heartbeats. See https://discord.com/developers/docs/topics/gateway#heartbeating
    }
    
    /// Step 3 (final)  of connecting to the Discord Gateway
    /// https://discord.com/developers/docs/topics/gateway#identifying
    private func identify() -> AnyPublisher<ReadyPayload, GatewayError> {
        let payload = IdentifyPayload(token: Secrets.discordToken)
        let identifyMessage = GatewayMessage(opCode: .identify, payload: .identity(payload))
        
        send(identifyMessage)
        
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
                            
                            guard let incomingMessage = self.decodeMessage(from: messageData) else {
                                fulfill(.failure(.decodingFailed))
                                return
                            }
                            
                            guard case .dispatch(.ready(let readyPayload)) = incomingMessage.payload else {
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
            
            defer {
                // Foundation only lets this closure run once, so we must re-register it. 🤷‍♀️
                self.listenForMessages()
            }
            
            let messageData: Data?
            switch result {
            case .success(let message):
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
                
                let message = self.decodeMessage(from: messageData)
                
                if case .dispatch(let event) = message?.payload {
                    self.eventSubject.send(event)
                }

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
