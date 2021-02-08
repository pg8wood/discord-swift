//
//  Guild.swift
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
                .compactMap(\.user).removingDuplicates()
        }
        
        return voiceStateMembers.compactMap(\.user).removingDuplicates()
    }
}

// TODO: see why the gateway is returning duplicate members!
private extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}


struct VoiceState: Codable, Hashable, Equatable {
    var userID: Snowflake
    var member: GuildMember?
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
    }
}

struct GuildMember: Codable, Hashable, Equatable {
    let user: User?
}
