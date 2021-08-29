//
//  UserView.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 8/29/21.
//

import SwiftUI
import Swiftcord

struct UserView: View {
    let user: User
    
    var body: some View {
        HStack {
            AvatarImage(user: user)
            
            Text(user.username)
        }
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView(user: .mockUser)
    }
}
