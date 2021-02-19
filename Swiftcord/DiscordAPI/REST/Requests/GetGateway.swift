//
//  GetGateway.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 11/24/20.
//

import Foundation

struct GetGatewayRequest: APIRequest {
    typealias Response = Gateway
    var path: String {
        "/gateway/bot"
    }
}
