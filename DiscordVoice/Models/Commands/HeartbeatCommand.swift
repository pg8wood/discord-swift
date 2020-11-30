//
//  HeartbeatCommand.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 11/30/20.
//

import Foundation

/// https://discord.com/developers/docs/topics/gateway#heartbeat-example-heartbeat
struct HeartbeatCommand: Codable {
    let mostRecentSequenceNumber: Int?
    
    enum CodingKeys: String, CodingKey {
        case mostRecentSequenceNumber = "d"
    }
}
