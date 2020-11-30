//
//  Guild.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 11/24/20.
//

import Foundation

/// https://discord.com/developers/docs/resources/guild#guild-object
struct GuildPayload: Codable, Hashable, Equatable {
    let id: Snowflake
    let name: String
    let icon: String?
    let voiceStates: [VoiceState]
    let members: [GuildMember]
    
    enum CodingKeys: String, CodingKey {
        case voiceStates = "voice_states"
        case id, name, icon, members
    }
    
    var usersInVoiceChat: [User] {
        let voiceStateMembers = voiceStates.compactMap(\.member)
        
        if voiceStateMembers.isEmpty {
            let idsOfMembersInVoice = voiceStates.map(\.userID)
            return members
                .filter {
                guard let userID = $0.user?.id else {
                    return false
                }
                
                return idsOfMembersInVoice.contains(userID)
            }
                .compactMap(\.user)
        }
        
        return voiceStateMembers.compactMap(\.user)
    }
}

struct VoiceState: Codable, Hashable, Equatable {
    var userID: Snowflake
    var member: GuildMember?
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
    }
}

typealias Snowflake = String // TODOO make this a real type

struct GuildMember: Codable, Hashable, Equatable {
    let user: User?
}
