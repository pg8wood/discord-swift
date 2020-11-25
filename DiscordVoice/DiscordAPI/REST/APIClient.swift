//
//  APIClient.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 11/24/20.
//

import Foundation
import Combine

protocol APIClient {
    func get<T: APIRequest>(_ request: T) -> AnyPublisher<T.Response, Error> // TODO enumerate api errors
}
