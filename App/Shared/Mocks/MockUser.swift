//
//  MockUser.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 2/16/21.
//

import Foundation
import Swiftcord

extension User {
    static var mockUser: User {
        User(id: "42", username: "Mocky", avatar: nil)
    }
}
