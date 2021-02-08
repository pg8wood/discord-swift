//
//  GuildPreviewView.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 12/7/20.
//

import SwiftUI
import Combine

struct GuildPreviewScrollView: View {
    @Binding var guilds: [GuildPayload]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            ForEach(guilds, id: \.self) { guild in
                GuildPreviewView(guild: guild)
            }
        }
    }
}

struct GuildPreviewView_Previews: PreviewProvider {
    private static var guilds: [GuildPayload] {
        [
            "Short name",
            "Test Guild with a long-ish name"
        ].map {
            GuildPayload(id: "",
                         name: $0,
                         icon: "",
                         voiceStates: [
                            VoiceState(userID: "3", member: GuildMember(user: User(id: "3", username: "Always in Voice")))
                         ],
                         members: [])
        }
    }
    
    static var previews: some View {
        Group {
            GuildPreviewScrollView(guilds: .constant(guilds))
            
            GuildPreviewScrollView(guilds: .constant([]))
        }
    }
}

struct GuildPreviewView: View {
    @EnvironmentObject var gatewayHolder: DiscordAPIGateway
    @State private var image: UIImage? = UIImage(systemName: "photo")
    @State private var cancellables = Set<AnyCancellable>()

    var guild: GuildPayload
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label {
                Text(guild.name)
            } icon: {
                Image(uiImage: image ?? UIImage(systemName: "xmark.octagon.fill")!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: 75, maxHeight: 75)
                    .clipShape(Circle())
                    .onAppear {
                        // TODO: should this be done immediately when a Guild is loaded from the API instead of waiting for this view to appear?
                        gatewayHolder.getIcon(for: guild)
                            .assign(to: \.image, on: self)
                            .store(in: &cancellables)
                    }
            }
            .lineLimit(2)
            .minimumScaleFactor(0.5)
            .font(.title)
            .padding(.leading, -3) // Dunno why this extra bit of padding exists here
            .labelStyle(VerticallyCenteredLabelImageAlignmentStyle())
            
            voicePresencesView
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
    
    private var voicePresencesView: some View {
        if guild.usersInVoiceChat.isEmpty {
            return Label("No one's here", systemImage: "moon.zzz").eraseToAnyView()
        }
        
        return Group {
            Label("Voice States", systemImage: "speaker.wave.2.circle")
                .font(Font.body.weight(.bold))
            
            ForEach(guild.usersInVoiceChat, id: \.self) { user in
                HStack {
                    Circle()
                        .foregroundColor(.gray)
                        .frame(width: 35, height: 35)
                        .overlay(firstCharacterView(from: user.username))
                    
                    Text(user.username)
                }
            }
        }
        .eraseToAnyView()
    }
    
    private func firstCharacterView(from string: String) -> some View {
        Text("\(String(string.prefix(1)))")
            .foregroundColor(.white)
    }
}
