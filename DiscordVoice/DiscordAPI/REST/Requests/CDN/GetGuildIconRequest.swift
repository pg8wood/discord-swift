//
//  GetGuildIconRequest.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 2/7/21.
//

import UIKit

struct GetGuildIconRequest: APIRequest {
    typealias Response = UIImage

    let guildID: Snowflake
    let iconHash: String
    
    let baseURL = URL(string: "https://cdn.discordapp.com/")!
    var path: String { "icons/\(guildID)/\(iconHash).png" }
    
    func decodeResponse(from data: Data) throws -> Response {
        guard let image = UIImage(data: data) else {
            throw NSError() // TODO make a real error type
        }
        
        return image
    }
}
