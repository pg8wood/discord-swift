//
//  VoicePresencesView.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 2/8/21.
//

import SwiftUI

struct VoicePresencesListView: View {
    @Binding var guild: GuildPayload
    
    var body: some View {
        if guild.usersInVoiceChat.isEmpty {
            return Label("No one's here", systemImage: "moon.zzz").eraseToAnyView()
        }
        
        return Group {
            Label("Voice States", systemImage: "speaker.wave.2.circle")
                .font(Font.body.weight(.bold))
            
            ForEach(guild.usersInVoiceChat, id: \.self) { user in
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
