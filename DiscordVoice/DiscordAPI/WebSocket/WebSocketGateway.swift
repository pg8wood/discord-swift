//
//  WebSocketGateway.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 11/25/20.
//

import Foundation
import Combine

enum GatewayError: LocalizedError {
    case initialConnectionFailed
    case decodingFailed
    case webSocket(Error)
    case http(APIError)
    
    var errorDescription: String? {
        switch self {
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

protocol WebSocketGateway {
    var session: URLSession { get }
    var discordAPI: APIClient { get }
    var eventPublisher: AnyPublisher<Event, Never> { get }
    
    func connect() -> AnyPublisher<ReadyPayload, GatewayError>
    func send(command: Command)
}
