//
//  Guild.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 2/8/21.
//

import Combine

class Guild: ObservableObject, Equatable, Identifiable {
    static func == (lhs: Guild, rhs: Guild) -> Bool {
        lhs.id == rhs.id
    }
    
    let id: Snowflake
    let name: String
    var iconHash: String?
    @Published var voiceStates: [VoiceState]
    //    @Published var icon: UIImage? // TODO
    @Published var members: [GuildMember]
    @Published var channels: [Channel]
    
    var voiceChannels: [Channel] {
        channels.filter { $0.type == .guildVoice }
    }
    
    init(from payload: GuildPayload) {
        id = payload.id
        name = payload.name
        iconHash = payload.icon
        voiceStates = payload.voiceStates
        members = payload.members
        channels = payload.channels
    }
    
    func users(in voiceChannel: Channel) -> [User] {
        voiceStates
            .filter { $0.channelID == voiceChannel.id }
            .compactMap { voiceState in
                if let user = voiceState.member?.user {
                    return user
                }
                
                // Voice State Update events include members, but the Guild's initial
                // Voice States omit them for some reason
                return members
                    .compactMap(\.user)
                    .first(where: { $0.id == voiceState.userID })
            }
    }
    
    // TODO: can we use "assign" to subscribe guilds to their state updates instead of using sink?
    func didReceiveVoiceStateUpdate(_ voiceState: VoiceState) {
        guard let index = voiceStates.firstIndex(where: { $0.userID == voiceState.userID }) else {
            voiceStates.append(voiceState)
            return
        }
        
        voiceStates[index] = voiceState
    }
}

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
