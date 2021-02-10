//
//  VoicePresencesView.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 2/8/21.
//

import SwiftUI

struct VoicePresencesListView: View {
    @Binding var guild: Guild
    
    var body: some View {
        ForEach(guild.channelsByCategory.keys.sorted(by: { $0.position < $1.position })) { category in
            EasyExpandingDisclosureGroup {
                ForEach(guild.channelsByCategory[category] ?? []) { channel in
                    ChannelListItemView(guild: $guild, channel: channel)
                }
            } label: {
                Text(category.name)
            }
        }
    }
    
    
}

//struct VoicePresencesView_Previews: PreviewProvider {
//    static var previews: some View {
//        VoicePresencesView(guild: .constantt)
//    }
//}
