//
//  HelloPayload.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 11/24/20.
//

import Foundation

struct HelloPayload: Codable {
    let heartbeatInterval: Int
    
    enum CodingKeys: String, CodingKey {
        case heartbeatInterval = "heartbeat_interval"
    }
}
