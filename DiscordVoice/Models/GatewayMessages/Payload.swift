//
//  Payload.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 11/24/20.
//

import Foundation

enum Payload {
    case dispatch(DiscordEvent)
    case heartbeat
    case identity(IdentifyPayload)
    case hello(HelloPayload)
    case unknown
    
    var opCode: Int {
        switch self {
        case .dispatch: return 0
        case .heartbeat: return 1
        case .identity: return 2
        case .hello: return 10
        case .unknown: return -1
        }
    }
    
    /// https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-opcodes
    enum OpCode: Int, Codable {
        case dispatch = 0 // Indicates an event of type DiscordEvent was dispatched
        case heartbeat = 1
        case identify = 2
        case hello = 10
    }
}
