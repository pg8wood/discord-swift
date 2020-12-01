//
//  Payload.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 11/24/20.
//

import Foundation

/// The inner content of a message sent or received from the Gateway.
///
///https://discord.com/developers/docs/topics/gateway#payloads-gateway-payload-structure
enum Payload {
    case command(Command)
    case event(Event)
    
    var opCode: OpCode {
        switch self {
        case .command(let command):
            return command.opCode
        case .event(let event):
            return event.opCode
        }
    }
    
    /// https://discord.com/developers/docs/topics/opcodes-and-status-codes#gateway-gateway-opcodes
    enum OpCode: Int, Codable {
        case dispatch = 0 // Indicates an event of type DiscordEvent was dispatched
        case heartbeat = 1
        case identify = 2
        case requestGuildMembers = 8
        case hello = 10
        case heartbeatAcknowledged = 11
    }
}
