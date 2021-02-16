//
//  WebSocketGateway.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 11/25/20.
//

import Foundation
import Combine

enum GatewayError: LocalizedError {
    case invalidRequest
    case initialConnectionFailed
    case decodingFailed
    case webSocket(Error)
    case http(APIError)
    
    var errorDescription: String? {
        switch self {
        case .invalidRequest:
            return "Invalid request"
        case .initialConnectionFailed:
            return "Connecting to Discord failed"
        case .decodingFailed:
            return "Failed to decode response from Discord!"
        case .webSocket(let error):
            return "Web socket error: \(error.localizedDescription)"
        case .http(let apiError):
            return apiError.localizedDescription
        }
    }
}

/// Credit to this fantastic answer: https://stackoverflow.com/a/61627636
protocol URLSessionProtocol {
    typealias APIResponse = URLSession.DataTaskPublisher.Output
    func apiResponse(for request: URLRequest) -> AnyPublisher<APIResponse, URLError>
    
    func webSocketTask(with url: URL) -> URLSessionWebSocketTask
}

extension URLSession: URLSessionProtocol {
    func apiResponse(for request: URLRequest) -> AnyPublisher<APIResponse, URLError> {
        return dataTaskPublisher(for: request).eraseToAnyPublisher()
    }
}

protocol WebSocketGateway {
//    var session: URLSessionProtocol { get }
    var discordAPI: APIClient { get }
    var eventPublisher: AnyPublisher<Event, Never> { get }
    
    func connect() -> AnyPublisher<ReadyPayload, GatewayError>
    func send(command: Command)
}
