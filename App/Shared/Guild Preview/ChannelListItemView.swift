//
//  GuildChannelListView.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 2/10/21.
//

import SwiftUI
import Combine
import Swiftcord

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
                .transition(.scale) // could be cool to do a custom animation that does a reverse scale spring animation (like how the ToastView does a reverse spring)
            }
        }
        .padding(.vertical, 4)
        .animation(.spring(dampingFraction: 0.50))
        
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

struct ChannelListItemView_Previews: PreviewProvider {
    /// A wrapper for the text State variable. If you just use a State variable in the PreviewProvider,
    /// the view's Binding won't update it for some reason.
    /// See: https://stackoverflow.com/questions/59246859/mutable-binding-in-swiftui-live-preview
    /// TODO: can this be created with a Result builder?
    struct BindingHolder: View {
        @State private var fbiAgentCount = 1
        @State private var voiceChannelWithUsers: VoiceChannel = {
            let voiceChannel = VoiceChannel(type: .guildVoice, name: "Poppin' Voice Channel")
            voiceChannel.usersInVoice.append(contentsOf: [
                "Mocky",
                "Mocky's Friend",
                "FBI Agent"
            ].map { username in
                User(id: "", username: username, avatar: nil)
            })
            return voiceChannel
        }()
        
        var body: some View {
            VStack(spacing: 16) {
                ChannelListItemView(channel: voiceChannelWithUsers)
                
                Button {
                    withAnimation {
                        fbiAgentCount += 1
                        voiceChannelWithUsers.usersInVoice.append(
                            User(id: "", username: "FBI Agent \(fbiAgentCount)", avatar: nil))
                    }
                } label: {
                    Text("Add FBI Agent")
                }
                
                Button {
                    withAnimation {
                        fbiAgentCount -= 1
                        voiceChannelWithUsers.usersInVoice.removeLast()
                    }
                } label: {
                    Text("Disconnect user")
                        .foregroundColor(.red)
                }
            }
        }
    }
   
    @State private static var test = 1
    
    static var previews: some View {
        Group {
            ChannelListItemView(channel: Channel(type: .guildText, name: "Text Channel"))
            ChannelListItemView(channel: VoiceChannel(type: .guildVoice, name: "Empty Voice Channel"))
            BindingHolder()
        }
        .environmentObject(DiscordAPIGateway(gateway: MockGateway()))
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

private extension Channel {
    convenience init(type: ChannelType, name: Snowflake) {
        self.init(
            id: "42",
            type: type,
            guildID: nil,
            name: name,
            position: nil,
            parentID: nil)
        
    }
}
