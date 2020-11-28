//
//  discord_voiceApp.swift
//  Shared
//
//  Created by Patrick Gatewood on 11/27/20.
//

import SwiftUI
import Combine

@main
struct discord_voiceApp: App {
    @State private var gateway = DiscordGateway(session: .shared, discordAPI: DiscordAPI())
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: HomeViewModel(gateway: gateway))
        }
    }
}
