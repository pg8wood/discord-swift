//
//  DiscordAPI.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 11/24/20.
//

import UIKit
import Combine

class DiscordAPI: APIClient {
    private let myUserID = "275833464618614784"
    
    let session: URLSession = .shared // DI and make testable
    
    func get<T: APIRequest>(_ request: T) -> AnyPublisher<T.Response, APIError> {
        // all url construction should be in the request type
        let url = request.baseURL.appendingPathComponent(request.path)
        var urlRequest = URLRequest(url: url)
        
        request.headers.forEach {
            urlRequest.setValue($0.value, forHTTPHeaderField: $0.key)
        }
        
        return session.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .tryMap(request.decodeResponse)
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
