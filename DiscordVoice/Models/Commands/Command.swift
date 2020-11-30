//
//  Command.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 11/30/20.
//

import Foundation

enum Command {
    case heartbeat(HeartbeatCommand)
    case identity(IdentifyCommand)
    
    var opCode: Payload.OpCode {
        switch self {
        case .heartbeat: return .heartbeat
        case .identity: return .identify
        }
    }
}
