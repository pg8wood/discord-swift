//
//  Gateway.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 11/24/20.
//

import Foundation

struct Gateway: Codable {
    var url: URL
    var shards: Int
}
