//
//  GuildChannelListView.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 2/10/21.
//

import SwiftUI
import Combine

struct VoiceChannelView: View {
    @ObservedObject var voiceChannel: VoiceChannel
    
    var body: some View {
        Text("\(voiceChannel.usersInVoice.count)")
    }
}

struct ChannelListItemView: View {
    @ObservedObject var channel: Channel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Label {
                    Text(channel.name)
                } icon: {
                    Image(systemName: systemImageName(for: channel.type))
                }
                
                Spacer()
            }
            
            if let voiceChannel = channel as? VoiceChannel {
                ForEach(voiceChannel.usersInVoice, id: \.self) { user in
                    HStack {
                        AvatarImage(user: user)
                        
                        Text(user.username)
                    }
                }
                .padding(.leading, 35)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func systemImageName(for channelType: ChannelType) -> String {
        switch channelType {
        case .guildText:
            return "number"
        case .guildVoice:
            return "speaker.wave.2.fill"
        default:
            return "questionmark"
        }
    }
}

//struct ChannelListItemView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChannelListItemView(guild: <#T##Binding<Guild>#>, channel: <#T##Channel#>)
//    }
//}
