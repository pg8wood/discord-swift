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
    let limit: Int
    let userIDs: [Snowflake]
    
    // TODO add optional fields
    
    enum CodingKeys: String, CodingKey {
        case guildID = "guild_id"
        case userIDs = "user_ids"
        case limit
    }
    
    init(guildID: Snowflake, userIDs: [Snowflake], limit: Int = 0) {
        self.guildID = guildID
        self.userIDs = userIDs
        self.limit = limit
    }
}
