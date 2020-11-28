//
//  ReadyPayload.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 11/25/20.
//

import Foundation

/// https://discord.com/developers/docs/topics/gateway#ready
struct ReadyPayload: Codable, Hashable, Equatable {
    let gatewayVersion: Int
    let user: User
    let sessionID: String
    
    enum CodingKeys: String, CodingKey {
        case gatewayVersion = "v"
        case sessionID = "session_id"
        case user
    }
}
