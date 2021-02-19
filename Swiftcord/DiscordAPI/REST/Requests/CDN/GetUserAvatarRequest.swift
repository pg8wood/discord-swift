//
//  GetUserAvatarRequest.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 2/7/21.
//

import UIKit

struct GetUserAvatarRequest: APIRequest {
    typealias Response = UIImage

    let userID: Snowflake
    let avatar: String
    
    let baseURL = URL(string: "https://cdn.discordapp.com/")!
    var path: String { "avatars/\(userID)/\(avatar).png" }
    
    func decodeResponse(from data: Data) throws -> Response {
        guard let image = UIImage(data: data) else {
            throw NSError() // TODO make a real error type
        }

        return image
    }
}
