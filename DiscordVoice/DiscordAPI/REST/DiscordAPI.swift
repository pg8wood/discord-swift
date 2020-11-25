//
//  DiscordAPI.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 11/24/20.
//

import Foundation
import Combine

class DiscordAPI: APIClient {
    private let baseURL = URL(string: "https://discord.com/api")!
    private let myUserID = "275833464618614784"
    
    let session: URLSession = .shared // DI and make testable
    
    func get<T: APIRequest>(_ request: T) -> AnyPublisher<T.Response, APIError> {
        let url = baseURL.appendingPathComponent(request.path)
        var urlRequest = URLRequest(url: url)
        
        request.headers.forEach {
            urlRequest.setValue($0.value, forHTTPHeaderField: $0.key)
        }
        
        return session.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .decode(type: T.Response.self, decoder: JSONDecoder())
            .mapError { error -> APIError in
                switch error {
                case is DecodingError:
                    return .decodingFailed
                case let urlError as URLError:
                    return .sessionFailed(urlError)
                default:
                    return .unknown(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func getMyUser() -> AnyPublisher<User, APIError> {
        get(GetUserRequest(userID: myUserID))
    }
}
