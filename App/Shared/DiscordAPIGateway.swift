//
//  DiscordAPIGateway.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 2/7/21.
//

import UIKit
import Combine

class DiscordAPIGateway: ObservableObject {
    @Published var gateway: WebSocketGateway
    
    private var cancellables = Set<AnyCancellable>()
    
    init(gateway: WebSocketGateway = DiscordGateway(session: URLSession.shared, discordAPI: DiscordAPI(session: URLSession.shared))) {
        self.gateway = gateway
    }
    
    func getIcon(for guild: Guild) -> AnyPublisher<UIImage?, Never> {
        Deferred {
            Future { [weak self] fulfill in
                guard let self = self,
                      let guildIcon = guild.iconHash else {
                    fulfill(.success(nil))
                    return
                }
                
                self.gateway.discordAPI.get(GetGuildIconRequest(guildID: guild.id, iconHash: guildIcon))
                    .receive(on: DispatchQueue.main)
                    .sink( receiveCompletion:  { completion in
                        switch completion {
                        case .failure:
                            fulfill(.success(nil))
                        case .finished: break
                        }
                    }, receiveValue: { image in
                        fulfill(.success(image))
                    })
                    .store(in: &self.cancellables)
            }
        }
        .eraseToAnyPublisher()
    }
    
    func getAvatar(for user: User) -> AnyPublisher<UIImage?, Never> {
        Deferred {
            Future { [weak self] fulfill in
                guard let self = self,
                      let avatar = user.avatar else {
                    fulfill(.success(nil))
                    return
                }
                
                self.gateway.discordAPI.get(GetUserAvatarRequest(userID: user.id, avatar: avatar))
                    .receive(on: DispatchQueue.main)
                    .sink( receiveCompletion:  { completion in
                        switch completion {
                        case .failure:
                            fulfill(.success(nil))
                        case .finished: break
                        }
                    }, receiveValue: { image in
                        fulfill(.success(image))
                    })
                    .store(in: &self.cancellables)
            }
        }
        .eraseToAnyPublisher()
    }
}

extension DiscordAPIGateway {
    static var mockGateway: DiscordAPIGateway {
        DiscordAPIGateway(gateway: MockGateway())
    }
}
