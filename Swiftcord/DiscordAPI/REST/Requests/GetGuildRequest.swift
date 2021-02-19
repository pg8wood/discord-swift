//
//  GetGuildRequest.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 11/27/20.
//

import Foundation

struct GetGuildRequest: APIRequest {
    typealias Response = GuildPayload
    
    var id: String
    
    var path: String {
        "/guilds/id"
    }
}
