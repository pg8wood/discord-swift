//
//  VoicePresencesView.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 2/8/21.
//

import SwiftUI

struct VoicePresencesListView: View {
    @Binding var guild: Guild

    var body: some View {
        if guild.voiceStates.isEmpty {
            return Label("No one's here", systemImage: "moon.zzz").eraseToAnyView()
        }
        
        return ForEach(guild.voiceChannels, id: \.self) { voiceChannel in
            Group {
                Label(voiceChannel.name ?? "Unknown Channel", systemImage: "speaker.wave.2.circle")

                ForEach(guild.users(in: voiceChannel), id: \.self) { user in
                    HStack {
                        AvatarImage(user: user)

                        Text(user.username)
                    }
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
