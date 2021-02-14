//
//  GuildChannelListView.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 2/10/21.
//

import SwiftUI
import Combine

struct ChannelListItemView: View {
    /// SwiftUI bug / my misunderstanding alert:
    /// I've tried making `channel` an @EnvironmentObject, @ObservedObject, and a
    /// one-way binding (kludge), but even when the `channel` object is absolutely
    /// updated in the parent view such that the parent view updates, this view will NOT
    /// update unless it is observing the actual @Binding of the parent view.
    ///
    /// I suspect this has something to do with the computed property `sortedChannelCategories`
    /// in the parent view, but none of the SwiftUI documentation says that using a computed
    /// property isn't allowed 🤷‍♀️
    @Binding var channelsByCategory: [Channel: [Channel]]
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
