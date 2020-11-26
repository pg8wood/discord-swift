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
}

protocol WebSocketGateway {
    var session: URLSession { get }
    var discordAPI: APIClient { get }
    
    func connect() -> AnyPublisher<ReadyPayload, GatewayError>
}
