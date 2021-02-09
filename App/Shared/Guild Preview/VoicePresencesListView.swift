//
//  VoicePresencesView.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 2/8/21.
//

import SwiftUI

struct VoicePresencesListView: View {
    @Binding var guild: Guild
    
//    // TODO: see if u can get the list of users in chat again because discord only sends events instead of the updated collection
//    @State private var usersInVoiceChat: [User] = []
    
    private var usersInVoiceChat: [User] {
        guild.voiceStates
            .filter { $0.channelID != nil }
            .compactMap(\.member?.user)
    }
    
    var body: some View {
        if guild.voiceStates.isEmpty {
            return Label("No one's here", systemImage: "moon.zzz").eraseToAnyView()
        }

        return Group {
            Label("Members", systemImage: "speaker.wave.2.circle")
                .font(Font.body.weight(.bold))

            ForEach(usersInVoiceChat, id: \.self) { user in
                
                HStack {
                    AvatarImage(user: user)

                    Text(user.username)
                }
            }
        }
        .eraseToAnyView()   
    }
}

//struct VoicePresencesView_Previews: PreviewProvider {
//    static var previews: some View {
//        VoicePresencesView(guild: .constantt)
//    }
//}
