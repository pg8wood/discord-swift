//
//  Event.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 11/30/20.
//

import Foundation

enum Event: Hashable {
    case dispatch(DiscordEvent)
    case hello(HelloPayload)
    
    var opCode: Payload.OpCode {
        switch self {
        case .dispatch: return .dispatch
        case .hello: return .hello
        }
    }
    
    var name: String {
        switch self {
        case .dispatch(let event):
            return event.name
        case .hello:
            return "Hello"
        }
    }
}
