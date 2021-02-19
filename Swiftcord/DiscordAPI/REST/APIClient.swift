//
//  APIClient.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 11/24/20.
//

import Foundation
import Combine

enum APIError: LocalizedError {
    case sessionFailed(URLError)
    case decodingFailed
    case unknown(Error)
}

protocol APIClient {
    func get<T: APIRequest>(_ request: T) -> AnyPublisher<T.Response, APIError>
}
