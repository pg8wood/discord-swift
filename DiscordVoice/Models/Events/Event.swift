//
//  Event.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 11/30/20.
//

import Foundation

enum Event {
    case dispatch(DiscordEvent)
    case hello(HelloPayload)
    
    var opCode: Payload.OpCode {
        switch self {
        case .dispatch: return .dispatch
        case .hello: return .hello
        }
    }
}
