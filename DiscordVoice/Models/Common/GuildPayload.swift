//
//  GuildPayload.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 11/24/20.
//

import Foundation

/// https://discord.com/developers/docs/resources/guild#guild-object
struct GuildPayload: Codable, Hashable, Equatable, Identifiable {
    let id: Snowflake
    let name: String
    let icon: String?
    let voiceStates: [VoiceState]
    let members: [GuildMember]
    
    enum CodingKeys: String, CodingKey {
        case voiceStates = "voice_states"
        case id, name, icon, members
    }
}

struct VoiceState: Codable, Hashable, Equatable {
    let guildID: Snowflake?
    let userID: Snowflake
    let channelID: Snowflake?
    let member: GuildMember?
    
    enum CodingKeys: String, CodingKey {
        case guildID = "guild_id"
        case userID = "user_id"
        case channelID = "channel_id"
        case member
    }
}

struct GuildMember: Codable, Hashable, Equatable {
    let user: User?
}
