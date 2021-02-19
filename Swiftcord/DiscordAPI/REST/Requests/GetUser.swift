//
//  GetUser.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 11/24/20.
//

import Foundation

struct GetUserRequest: APIRequest {
    typealias Response = User
    
    let userID: String
    
    var path: String {
        "/users/\(userID)"
    }
}
