//
//  Channel.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 2/10/21.
//

import Foundation

class Channel: ObservableObject, Hashable, Equatable, Identifiable {
    static func == (lhs: Channel, rhs: Channel) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: Snowflake
    let type: ChannelType
    let guildID: Snowflake?
    let name: String
    let position: Int
    let parentID: Snowflake?
    
    init(from payload: ChannelPayload) {
        self.id = payload.id
        self.type = payload.type
        self.guildID = payload.guildID
        self.name = payload.name ?? "Unknown Channel"
        self.position = payload.position ?? -1
        self.parentID = payload.parentID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
