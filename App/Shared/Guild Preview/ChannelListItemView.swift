//
//  GuildChannelListView.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 2/10/21.
//

import SwiftUI

struct ChannelListItemView: View {
    @Binding var guild: Guild
    let channel: Channel
        
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
            
            if channel.type == .guildVoice {
                ForEach(guild.users(in: channel), id: \.self) { user in
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
