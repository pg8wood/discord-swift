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
    @Published var channelsByCategory: [Channel: [Channel]]
    
    var voiceChannels: [VoiceChannel] {
        channelsByCategory.values
            .flatMap {
                $0.compactMap { channel in
                    channel as? VoiceChannel
                }
            }
    }
    
    init(from payload: GuildPayload) {
        func organizeChannelsByCategory(_ channels: [ChannelPayload]) -> [Channel: [Channel]] {
            let typedChannels: [Channel] = channels.map {
                switch $0.type {
                case .guildVoice:
                    return VoiceChannel(from: $0)
                default:
                    return Channel(from: $0)
                }
            }
            let allChannels = Set(typedChannels)
            var categories = Set(allChannels.filter { $0.type == .guildCategory })
            
            let uncategorized = Channel.makeUncategorizedCategory()
            categories.insert(uncategorized)
            
            let nonCategoryChannels = allChannels.subtracting(categories)
            
            return Dictionary(
                grouping: nonCategoryChannels,
                by: { $0.parentID ?? Channel.uncategorizedChannelID })
                .compactMapKeys { channelID in
                    categories.first(where: { $0.id == channelID }) ?? uncategorized
                }
        }
        
        id = payload.id
        name = payload.name
        iconHash = payload.icon
        voiceStates = payload.voiceStates
        members = payload.members
        channelsByCategory = organizeChannelsByCategory(payload.channels)
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
