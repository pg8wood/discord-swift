//
//  Channel.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 2/9/21.
//

import Foundation

/// https://discord.com/developers/docs/resources/channel#channel-object
struct Channel: Codable, Hashable, Equatable, Identifiable {
    enum ChannelType: Int, Codable {
        case guildText = 0
        case directMessage
        case guildVoice
        case groupDirectMessage
        case guildCategory
        case guildNews
        case guildStore
    }
    
    let id: Snowflake
    let type: ChannelType
    let guildID: Snowflake?
    let name: String?
    
    enum CodingKeys: String, CodingKey {
        case guildID = "guild_id"
        case id, type, name
    }
}
