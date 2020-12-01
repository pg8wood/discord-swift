//
//  HelloPayload.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 11/24/20.
//

import Foundation

/// https://discord.com/developers/docs/topics/gateway#hello
struct HelloPayload: Codable, Hashable {
    let heartbeatInterval: Double // milliseconds
    
    enum CodingKeys: String, CodingKey {
        case heartbeatInterval = "heartbeat_interval"
    }
}
