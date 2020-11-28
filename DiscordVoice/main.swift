//
//  main.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 11/18/20.
//

import Combine
import Foundation

var cancellables = Set<AnyCancellable>()
let dispatchGroup = DispatchGroup()
let discordAPI = DiscordAPI()
let gateway: WebSocketGateway = DiscordGateway(session: .shared, discordAPI: discordAPI)

dispatchGroup.enter()

gateway.connect()
    .sink(receiveCompletion: { completion in
        print("WSS got completion")
        
        // Currently, keep the connection open indefinitely for testing
//        dispatchGroup.leave()
    }, receiveValue: { opCodeResponse in
        print("WSS got value: \(opCodeResponse)")
    })
    .store(in: &cancellables)

dispatchGroup.notify(queue: .main) {
    exit(0)
}

dispatchMain()
