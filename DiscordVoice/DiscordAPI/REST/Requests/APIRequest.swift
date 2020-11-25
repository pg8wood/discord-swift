//
//  APIRequest.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 11/24/20.
//

import Foundation

protocol APIRequest {
    associatedtype Response: Decodable
    
    var headers: [String: String] { get }
    var path: String { get }
}

extension APIRequest {
    var headers: [String: String] {
        [
            "Authorization": "Bot \(Secrets.discordToken)"
        ]
    }
}
