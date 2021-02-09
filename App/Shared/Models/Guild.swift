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
    
//    var usersInVoiceChat: [User] {
//        let voiceStateMembers = voiceStates.compactMap(\.member)
//
//        if voiceStateMembers.isEmpty {
//            let idsOfMembersInVoice = voiceStates.map(\.userID)
//            return members
//                .filter {
//                    guard let userID = $0.user?.id else {
//                        return false
//                    }
//
//                    return idsOfMembersInVoice.contains(userID)
//                }
//                .compactMap(\.user).removingDuplicates()
//        }
//
//        return voiceStateMembers.compactMap(\.user).removingDuplicates()
//    }
    
    init(from payload: GuildPayload) {
        self.id = payload.id
        self.name = payload.name
        self.iconHash = payload.icon
        self.voiceStates = payload.voiceStates
        self.members = payload.members
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
