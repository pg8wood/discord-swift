//
//  RequestGuildMembersCommand.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 11/30/20.
//

import Foundation

/// https://discord.com/developers/docs/topics/gateway#request-guild-members-guild-request-members-structure
struct RequestGuildMembersCommand: Codable {
    let guildID: Snowflake
    let query: String = ""
    let limit: Int = 0
    let presences: Bool = true
    
    enum CodingKeys: String, CodingKey {
        case guildID = "guild_id"
        case query
        case limit, presences
    }
}
