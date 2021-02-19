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
    
    var body: some View {
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

//struct VoicePresencesView_Previews: PreviewProvider {
//    static var previews: some View {
//        VoicePresencesView(guild: .constantt)
//    }
//}
