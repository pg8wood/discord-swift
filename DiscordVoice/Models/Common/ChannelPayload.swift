//
//  Channel.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 2/9/21.
//

import Foundation

enum ChannelType: Int, Codable {
    case guildText = 0
    case directMessage
    case guildVoice
    case groupDirectMessage
    case guildCategory
    case guildNews
    case guildStore
}

/// https://discord.com/developers/docs/resources/channel#channel-object
struct ChannelPayload: Codable, Hashable {
    let id: Snowflake
    let type: ChannelType
    let guildID: Snowflake?
    let name: String?
    let position: Int?
    let parentID: Snowflake?
    
    enum CodingKeys: String, CodingKey {
        case guildID = "guild_id"
        case parentID = "parent_id"
        case id, type, name, position
    }
}
