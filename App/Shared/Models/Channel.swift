//
//  Channel.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 2/10/21.
//

import Foundation
import Combine

class Channel: ObservableObject, Hashable, Equatable, Identifiable {
    static func == (lhs: Channel, rhs: Channel) -> Bool {
        lhs.uuid == rhs.uuid
    }
 
    static var uncategorizedChannelID: Snowflake = "Uncategorized"
    static func makeUncategorizedCategory() -> Channel {
        Channel(from: ChannelPayload(
                    id: uncategorizedChannelID,
                    type: .guildCategory,
                    guildID: nil,
                    name: uncategorizedChannelID,
                    position: -1,
                    parentID: nil))
    }
    fileprivate let uuid = UUID()
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

class VoiceChannel: Channel {
    @Published var usersInVoice: [User] = []
    
    func observe(voiceStates: AnyPublisher<[VoiceState], Never>,
                 on guild: Guild) -> AnyCancellable {
        voiceStates.sink { [weak self] newVoiceStates in
            guard let self = self else { return }
            
            self.usersInVoice = newVoiceStates.filter {
                $0.channelID == self.id
            }
            .compactMap { voiceState in
                if let user = voiceState.member?.user {
                    return user
                }
                
                // Voice State Update events include members, but the Guild's initial
                // Voice States omit them for some reason
                return guild.members
                    .compactMap(\.user)
                    .first(where: { $0.id == voiceState.userID })
            }
        }
    }
}
