//
//  DiscordEvent.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 11/24/20.
//

import Foundation

enum DiscordEvent: Hashable {
    static func == (lhs: DiscordEvent, rhs: DiscordEvent) -> Bool {
        switch (lhs, rhs) {
        case (.ready(let lhsValue), .ready(let rhsValue)):
            return lhsValue == rhsValue
        case (.guildCreate(let lhsValue), .guildCreate(let rhsValue)):
            return lhsValue == rhsValue
        default: return false
        }
    }
    
    case ready(ReadyPayload)
    case guildCreate(GuildPayload)
    
    var name: String {
        switch self {
        case .ready:
            return DiscordEventType.ready.rawValue
        case .guildCreate:
            return DiscordEventType.guildCreate.rawValue
        }
    }
}

enum DiscordEventType: String, Codable {
    case ready = "READY"
    case guildCreate = "GUILD_CREATE"
}
