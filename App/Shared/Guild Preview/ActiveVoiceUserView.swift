//
//  ActiveVoiceUserView.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 8/28/21.
//

import SwiftUI
import Swiftcord

struct ActiveVoiceUserView: View {
    let user: User
    
    var body: some View {
        AvatarImage(user: user)
            .overlay(speakerOverlayView)
    }
    
    private var speakerOverlayView: some View {
        GeometryReader { geo in
            Circle()
                .foregroundColor(.black)
                .opacity(0.45)
                .overlay(Image(systemName: "speaker.wave.2.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geo.size.width * 0.35)
                            .foregroundColor(.white.opacity(0.75))
                )
        }
    }
    
}

struct ActiveVoiceUserView_Previews: PreviewProvider {
    static var previews: some View {
        ActiveVoiceUserView(user: .mockUser)
            .environmentObject(DiscordAPIGateway.mockGateway)
    }
}
