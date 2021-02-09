//
//  GuildPreviewView.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 12/7/20.
//

import SwiftUI
import Combine

struct GuildPreviewScrollView: View {
    @Binding var guilds: [Guild]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            ForEach(guilds.indices, id: \.self) { index in
                GuildPreviewView(guild: $guilds[index])
            }
        }
    }
}

struct GuildPreviewView_Previews: PreviewProvider {
    private static var guilds: [Guild] {
        [
            "Short name",
            "Test Guild with a long-ish name"
        ].map {
            Guild(from: GuildPayload(id: "",
                         name: $0,
                         icon: "",
                         voiceStates: [
                            VoiceState(guildID: "42", userID: "3", channelID: "22", member: GuildMember(user: User(id: "3", username: "Always in Voice", avatar: "test")))
                         ],
                         members: [])
            )
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
    @EnvironmentObject var discordGateway: DiscordAPIGateway
    @State private var image: UIImage? = UIImage(systemName: "photo")
    @State private var cancellables = Set<AnyCancellable>()

    @Binding var guild: Guild
    
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
                        discordGateway.getIcon(for: guild)
                            .assign(to: \.image, on: self)
                            .store(in: &cancellables)
                    }
            }
            .lineLimit(2)
            .minimumScaleFactor(0.5)
            .font(.title)
            .padding(.leading, -3) // Dunno why this extra bit of padding exists here
            .labelStyle(VerticallyCenteredLabelImageAlignmentStyle())
            
            VoicePresencesListView(guild: $guild)
                .environmentObject(discordGateway)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
}
