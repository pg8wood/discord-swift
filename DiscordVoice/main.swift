//
//  main.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 11/18/20.
//

import Combine
import Foundation

protocol APIRequest {
    associatedtype Response: Decodable
    
    var headers: [String: String] { get }
    var path: String { get }
}

extension APIRequest {
    var headers: [String: String] {
        [
            "Authorization": "Bot \(Secrets.discordToken)"
        ]
    }
}

struct GetUserRequest: APIRequest {
    typealias Response = User
    
    let userID: String
    
    var path: String {
        "/users/\(userID)"
    }
}

struct Gateway: Codable {
    var url: URL
    var shards: Int
}

struct GetGatewayRequest: APIRequest {
    typealias Response = Gateway
    var path: String {
        "/gateway/bot"
    }
}

struct User: Codable {
    let username: String
}

protocol APIClient {
    func get<T: APIRequest>(_ request: T) -> AnyPublisher<T.Response, Error>
}

class DiscordAPI: APIClient {
    private let baseURL = URL(string: "https://discord.com/api")!
    private let myUserID = "275833464618614784"
    
    
    let session: URLSession = .shared // DI and make testable
    
    func get<T: APIRequest>(_ request: T) -> AnyPublisher<T.Response, Error> {
        let url = baseURL.appendingPathComponent(request.path)
        var urlRequest = URLRequest(url: url)
        
        request.headers.forEach {
            urlRequest.setValue($0.value, forHTTPHeaderField: $0.key)
        }
        
        return session.dataTaskPublisher(for: urlRequest)
            .tryMap {
                print("data: \($0.data)\nresponse: \($0.response)")
                return $0.data
            } // use response/error for apierror
            .decode(type: T.Response.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func getMyUser() -> AnyPublisher<User, Error> {
        let getUserRequest = GetUserRequest(userID: myUserID)
        return get(getUserRequest)
    }
}

struct GatewayMessage<Payload: Codable>: Codable {
    let opCode: DiscordOpCode
    let payload: Payload
    let eventType: DiscordEventType?
    
    enum CodingKeys: String, CodingKey {
        case opCode = "op"
        case payload = "d"
        case eventType = "t"
    }
    
    init(opCode: DiscordOpCode, payload: Payload) {
        self.opCode = opCode
        self.payload = payload
        self.eventType = nil
    }
}

struct GatewayEventInfo: Codable {
    let eventType: DiscordEventType
    
    enum CodingKeys: String, CodingKey {
        case eventType = "t"
    }
}

// TODO: probably need to implement a custom decoder for the event types https://stackoverflow.com/questions/52896731/how-to-use-jsondecoder-to-decode-json-with-unknown-type
// is there a way to make this codable + use an associated type to bind the events to their types?
enum DiscordEventType: String, Codable {
    case guildCreate = "GUILD_CREATE"
}

/// https://discord.com/developers/docs/resources/guild#guild-object
struct GuildPayload: Codable {
    let name: String
}

struct HelloPayload: Codable {
    let heartbeatInterval: Int
    
    enum CodingKeys: String, CodingKey {
        case heartbeatInterval = "heartbeat_interval"
    }
}

struct IdentifyPayload: Codable {
    struct ConnectionProperties: Codable {
        let os: String
        let browser: String
        let device: String
        
        enum CodingKeys: String, CodingKey {
            case os = "$os"
            case browser = "$browser"
            case device = "$device"
        }
    }
    
    let token: String
    var properties = ConnectionProperties(os: "iOS", browser: "testing", device: "testing")
    var intents: Int = (1 << 0) // https://discord.com/developers/docs/topics/gateway#list-of-intents
}

/// https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-opcodes
enum DiscordOpCode: Int, Codable {
    case dispatch = 0 // Indicates an event of type DiscordEventType was dispatched
    case heartbeat = 1
    case identify = 2
    case hello = 10
}

class DiscordWSSAPI {
    let session: URLSession
    let discordAPI: DiscordAPI
    
    private let apiVersion = 8
//    private lazy var baseURL = URL(string: "wss://gateway.discord.gg/?v=\(apiVersion)&encoding=json")!
    private var cancellables = Set<AnyCancellable>()
    
    private var webSocketTask: URLSessionWebSocketTask?
    
    init(session: URLSession, discordAPI: DiscordAPI) {
        self.session = session
        self.discordAPI = discordAPI
    }
    
    // need result type for error handling maybe?
    func send<T: Codable>(_ message: GatewayMessage<T>) {
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
            if let eventInfo = try? decoder.decode(GatewayEventInfo.self, from: data) {
                switch eventInfo.eventType {
                case .guildCreate:
                    let guildCreateMesage = try decoder.decode(GatewayMessage<GuildPayload>.self, from: data)
                    print("got guild create message!")
                }
            }
//                let eventPayloadType = eventInfo.eventType.payloadType.self
//                let eventMessage = try decoder.decode(GatewayMessage<eventPayloadType>.self, from: data)
//            }
        } catch {
            print("error decoding message: \(error.localizedDescription)")
        }
    }
    
    func connect() -> AnyPublisher<GatewayMessage<HelloPayload>, Error> {
        let connectionSubject = PassthroughSubject<GatewayMessage<HelloPayload>, Error>()
        
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
                            let helloResponse = try JSONDecoder().decode(GatewayMessage<HelloPayload>.self, from: data)
                            connectionSubject.send(helloResponse)
                            self.beginHeartbeat(interval: helloResponse.payload.heartbeatInterval)
                            self.identify()
                        } catch {
                            print("error decoding Hello Payload response: \(error.localizedDescription)")
                            connectionSubject.send(completion: .failure(error))
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
        let identifyPayload = IdentifyPayload(token: Secrets.discordToken)
        let identifyMessage = GatewayMessage(opCode: .identify, payload: identifyPayload)
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


var cancellables = Set<AnyCancellable>()
let dispatchGroup = DispatchGroup()

dispatchGroup.enter()
DiscordWSSAPI(session: .shared, discordAPI: DiscordAPI())
    .connect()
    .sink(receiveCompletion: { completion in
        print("WSS got completion")
        dispatchGroup.leave()
    }, receiveValue: { opCodeResponse in
        print("WSS got value: \(opCodeResponse)")
    })
    .store(in: &cancellables)
//let discordAPI = DiscordAPI()
//discordAPI.getMyUser()
//    .sink(receiveCompletion: { completion in
//            switch completion {
//            case .failure(let error):
//                print(error)
//            case .finished: break
//            }
////        dispatchGroup.leave()
//    }, receiveValue: { user in
//        print("got user: \(user.username)")
//    })
//    .store(in: &cancellables)


dispatchGroup.notify(queue: .main) {
    exit(0)
}

dispatchMain()
