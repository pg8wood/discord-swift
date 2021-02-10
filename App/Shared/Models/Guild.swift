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
    
    var textChannels: [Channel] {
        channels.filter { $0.type == .guildText }
    }
    
    var channelCategories: [Channel] {
        channels.filter { $0.type == .guildCategory }
    }
    
    var channelsByCategory: [Channel: [Channel]] {
        Dictionary(grouping: channels, by: { $0.parentID ?? "unknown" })
            .compactMapKeys { channelID in
                channelCategories.first(where: { $0.id == channelID })
            }
    }
    
    init(from payload: GuildPayload) {
        id = payload.id
        name = payload.name
        iconHash = payload.icon
        voiceStates = payload.voiceStates
        members = payload.members
        channels = payload.channels.map(Channel.init)
    }
    
    func channel(id: Snowflake) -> Channel? {
        voiceChannels.first(where: { $0.id == id })
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

private extension Dictionary {
    func compactMapKeys<Transformed>(_ transform: (Key) throws -> Transformed?) rethrows -> [Transformed: Value] {
        .init(
            uniqueKeysWithValues: try compactMap { key, value in
                try transform(key).map { ($0, value) }
            }
        )
    }
}
