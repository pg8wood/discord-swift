//
//  MockGateway.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 2/15/21.
//

import Foundation
import Combine

extension DiscordAPIGateway {
    static var mockGateway: DiscordAPIGateway {
        DiscordAPIGateway(gateway: MockGateway())
    }
}

struct MockGateway: WebSocketGateway {
    var session: URLSessionProtocol
    var discordAPI: APIClient
    var eventPublisher: AnyPublisher<Event, Never>
    
    init(mockSession: MockURLSession = MockURLSession()) {
        self.session = mockSession
        discordAPI = DiscordAPI(session: mockSession)
        eventPublisher = PassthroughSubject<Event, Never>().eraseToAnyPublisher()
    }
    
    func connect() -> AnyPublisher<ReadyPayload, GatewayError> {
        PassthroughSubject<ReadyPayload, GatewayError>().eraseToAnyPublisher()
    }
    
    func send(command: Command) {
        // TODO
    }
}
