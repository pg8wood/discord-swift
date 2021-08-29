//
//  VoicePresencesView.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 2/8/21.
//

import SwiftUI
import Swiftcord

struct VoicePresencesListView: View {
    @Binding var channelsByCategory: [Channel: [Channel]]
    
    private var sortedChannelCategories: [Channel] {
        channelsByCategory.keys.sorted(by: {
            $0.position < $1.position
        })
    }
    
    private var usersInVoice: [User] {
        channelsByCategory.values
            .flatMap { $0 }
            .compactMap { $0 as? VoiceChannel }
            .flatMap { $0.usersInVoice }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                ForEach(usersInVoice, id: \.self) { user in
                    ActiveVoiceUserView(user: user)
                }
            }
            
            ForEach(sortedChannelCategories) { category in
                if let channels = channelsByCategory[category] {
                    EasyExpandingDisclosureGroup {
                        ForEach(channels) { channel in
                            ChannelListItemView(channel: channel)
                        }
                    } label: {
                        Text(category.name)
                    }
                }
            }
        }
    }
}

//struct VoicePresencesView_Previews: PreviewProvider {
//    static var previews: some View {
//        VoicePresencesView(guild: .constantt)
//    }
//}
