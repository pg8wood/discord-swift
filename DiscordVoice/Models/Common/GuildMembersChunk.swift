//
//  GuildMembersChunk.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 2/9/21.
//

import Foundation

/// https://discord.com/developers/docs/topics/gateway#guild-members-chunk
struct GuildMembersChunk: Codable, Hashable, Equatable {
    let guildID: Snowflake
    let members: [GuildMember]
    
    // TODO: handle pagination for large guilds
    enum CodingKeys: String, CodingKey {
        case guildID = "guild_id"
        case members
    }
}
