//
//  DiscordWSSAPI.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 11/24/20.
//

import Foundation
import Combine

class DiscordWSSAPI {
    let session: URLSession
    let discordAPI: DiscordAPI

    private var cancellables = Set<AnyCancellable>()
    private var webSocketTask: URLSessionWebSocketTask?
    
    init(session: URLSession, discordAPI: DiscordAPI) {
        self.session = session
        self.discordAPI = discordAPI
    }
    
    // need result type for error handling maybe?
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
    
    /// Call this after authenticating to keep listening for new incoming messages.
    private func listenForMessages() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            
            defer {
                // Foundation sure has a strange way of handling web socket message listeners...
                self.listenForMessages()
            }
            
            switch result {
            case .success(let message):
                print("got message: \(message)")
                switch message {
                case .data(let data):
                    self.decodeMessage(from: data)
                case .string(let string):
                    let data = string.data(using: .utf8)
                    self.decodeMessage(from: data)
                @unknown default:
                    print("got unknown message type!")
                    fatalError()
                }
            case .failure(let error):
                print("Failed to receive web socket message: \(error)")
            }
        }
    }
    
    private func decodeMessage(from data: Data?) {
        guard let data = data else {
            return
        }
        
        let decoder = JSONDecoder()
        do {
            let message = try decoder.decode(GatewayMessage.self, from: data)
            print(#"Got message code "\#(message.opCode)" \#(message.eventType != nil ? "| event name: \(message.eventType!)" : "")"#)
        } catch {
            print("error decoding message: \(error.localizedDescription)")
        }
    }
    
    func connect() -> AnyPublisher<GatewayMessage, Error> {
        let connectionSubject = PassthroughSubject<GatewayMessage, Error>()
        
        func openWSSConnection(at url: URL) {
            let task = session.webSocketTask(with: url)
            
            task.receive { [weak self] result in
                guard let self = self else {
                    return
                }
                
                switch result {
                case .success(let message):
                    func decodeResponse(from data: Data?) {
                        guard let data = data else {
                            print("failed to decode hello payload because no data was found")
                            connectionSubject.send(completion: .failure(NSError())) // TODO use error enum
                            return
                        }
                        
                        do {
                            let helloResponse = try JSONDecoder().decode(GatewayMessage.self, from: data)
                            guard case .hello(let payload) = helloResponse.payload else {
                                print("error decoding Hello Payload response!")
                                connectionSubject.send(completion: .failure(NSError())) // TODO use real errors - decodingFailed or something
                                return
                            }
                            
                            connectionSubject.send(helloResponse)
                            self.beginHeartbeat(interval: payload.heartbeatInterval)
                            self.identify()
                        } catch {
                            print("error decoding Hello Payload response: \(error.localizedDescription)")
                            connectionSubject.send(completion: .failure(error)) // TODO use real response decodingFailed or something
                        }
                    }
                    
                    // TODO need to keep this open and keep parsing messages
                    switch message {
                    case .data(let data):
                        decodeResponse(from: data)
                    case .string(let string):
                        decodeResponse(from: string.data(using: .utf8))
                    @unknown default:
                        print("Encountered a new web socket data type!")
                        fatalError()
                    }
                    
                case .failure(let error):
                    print("WSS got error: \(error.localizedDescription)")
                    connectionSubject.send(completion: .failure(error))
                }
            }
            
            webSocketTask = task
            task.resume()
        }
        
        discordAPI.get(GetGatewayRequest())
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print(error.localizedDescription)
                case .finished: break
                }
            }, receiveValue: { gateway in
                print("received gateway: \(gateway)")
                openWSSConnection(at: gateway.url)
            })
            .store(in: &cancellables)
        
        return connectionSubject.eraseToAnyPublisher()
    }
    
    /// Step 3 of connecting to Discord
    /// https://discord.com/developers/docs/topics/gateway#identifying
    private func identify() {
        let payload = IdentifyPayload(token: Secrets.discordToken)
        let identifyMessage = GatewayMessage(opCode: .identify, payload: .identity(payload))
        send(identifyMessage)
        
        webSocketTask?.receive { [weak self] result in
            print(result)
            // if Ready event is good...
            self?.listenForMessages()
        }
    }
    
    /// Step 2 of connecting to Discord and maintaining the connection
    /// https://discord.com/developers/docs/topics/gateway#heartbeating
    private func beginHeartbeat(interval: Int) {
        // TODO: necessary for the discord spec to actually send these heartbeats. See https://discord.com/developers/docs/topics/gateway#heartbeating
    }
}
