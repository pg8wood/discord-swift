//
//  DiscordEvent.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 11/24/20.
//

import Foundation

enum DiscordEvent {
    case guildCreate(GuildPayload)
}

enum DiscordEventType: String, Codable {
    case guildCreate = "GUILD_CREATE"
}
