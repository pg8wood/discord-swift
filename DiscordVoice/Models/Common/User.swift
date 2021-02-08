//
//  User.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 11/24/20.
//

import Foundation

struct User: Codable, Hashable, Equatable {
    let id: Snowflake
    let username: String
    let avatar: String?
}
