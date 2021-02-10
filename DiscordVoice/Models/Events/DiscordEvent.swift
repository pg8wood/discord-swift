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
        case (.guildUpdate(let lhsValue), .guildUpdate(let rhsValue)):
            return lhsValue == rhsValue
        case (.unknown(let lhsValue), .unknown(let rhsValue)):
            return lhsValue == rhsValue
        case (.voiceStateUpdate(let lhsValue), .voiceStateUpdate(let rhsValue)):
            return lhsValue == rhsValue
        case (.guildMembersChunk(let lhsValue), .guildMembersChunk(let rhsValue)):
            return lhsValue == rhsValue
        default:
            return false
        }
    }
    
    case ready(ReadyPayload)
    case guildCreate(GuildPayload)
    case guildUpdate(GuildPayload)
    case voiceStateUpdate(VoiceState)
    case guildMembersChunk(GuildMembersChunk)
    case unknown(String)
    
    var name: String {
        switch self {
        case .ready:
            return DiscordEventType.ready.rawValue
        case .guildCreate:
            return DiscordEventType.guildCreate.rawValue
        case .guildUpdate:
            return DiscordEventType.guildUpdate.rawValue
        case .voiceStateUpdate:
            return DiscordEventType.voiceStateUpdate.rawValue
        case .guildMembersChunk:
            return DiscordEventType.guildMembersChunk.rawValue
        case .unknown(let jsonString):
            let data = jsonString.data(using: .utf8) ?? Data()
            let dictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
            return "\(dictionary?["t"] ?? "Unknown Event") (Unsupported)"
        }
    }
}

enum DiscordEventType: String, Codable {
    case ready = "READY"
    case guildCreate = "GUILD_CREATE"
    case guildUpdate = "GUILD_UPDATE"
    case voiceStateUpdate = "VOICE_STATE_UPDATE"
    case guildMembersChunk = "GUILD_MEMBERS_CHUNK"
}
