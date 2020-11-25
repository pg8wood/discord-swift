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
    
    func get<T: APIRequest>(_ request: T) -> AnyPublisher<T.Response, Error> {
        let url = baseURL.appendingPathComponent(request.path)
        var urlRequest = URLRequest(url: url)
        
        request.headers.forEach {
            urlRequest.setValue($0.value, forHTTPHeaderField: $0.key)
        }
        
        return session.dataTaskPublisher(for: urlRequest)
            .tryMap {
                print("data: \($0.data)\nresponse: \($0.response)")
                return $0.data
            } // use response/error for apierror
            .decode(type: T.Response.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    func getMyUser() -> AnyPublisher<User, Error> {
        let getUserRequest = GetUserRequest(userID: myUserID)
        return get(getUserRequest)
    }
}
