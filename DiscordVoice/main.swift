//
//  main.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 11/18/20.
//

import Combine
import Foundation


var cancellables = Set<AnyCancellable>()
let dispatchGroup = DispatchGroup()

dispatchGroup.enter()
DiscordGateway(session: .shared, discordAPI: DiscordAPI())
    .connect()
    .sink(receiveCompletion: { completion in
        print("WSS got completion")
        dispatchGroup.leave()
    }, receiveValue: { opCodeResponse in
        print("WSS got value: \(opCodeResponse)")
    })
    .store(in: &cancellables)
//let discordAPI = DiscordAPI()
//discordAPI.getMyUser()
//    .sink(receiveCompletion: { completion in
//            switch completion {
//            case .failure(let error):
//                print(error)
//            case .finished: break
//            }
////        dispatchGroup.leave()
//    }, receiveValue: { user in
//        print("got user: \(user.username)")
//    })
//    .store(in: &cancellables)


dispatchGroup.notify(queue: .main) {
    exit(0)
}

dispatchMain()
