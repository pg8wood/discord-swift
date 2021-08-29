//
//  ChannelMessagesView.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 8/29/21.
//

import SwiftUI
import Combine
import Swiftcord

struct ChannelMessagesView: View {
    let discordGateway: DiscordAPIGateway
    @ObservedObject var channel: Channel
    @State private var messages: [ChannelMessage] = [] // TODO update on new message once this view is displayed
    @State private var cancellables: Set<AnyCancellable> = []
    
    var body: some View {
        if messages.isEmpty {
            Text("It's quiet... too quiet...")
                .onAppear {
                    discordGateway.getMessages(in: channel)
                        .assign(to: \.messages, on: self)
                        .store(in: &self.cancellables)
                }
        } else {
            List {
                ForEach(messages, id: \.id) { message in
                    MessageContentView(message: message)
                }
            }
        }
    }
}

struct MessageContentView: View {
    let message: ChannelMessage
    
    var body: some View {
        HStack(alignment: .top) {
            if let author = message.author {
                AvatarImage(user: author)
            }
            VStack(alignment: .leading, spacing: 10) {
                if let author = message.author {
                    Text(author.username).bold()
                }
                
                Text(message.content)
            }
        }
    }
}
