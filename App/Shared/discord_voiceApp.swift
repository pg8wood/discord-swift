//
//  discord_voiceApp.swift
//  Shared
//
//  Created by Patrick Gatewood on 11/27/20.
//

import SwiftUI
import Combine
import Swiftcord

@main
struct discord_voiceApp: App {
    @State private var discordGateway = DiscordAPIGateway()
    
    init() {
        Swiftcord.setup(discordToken: Secrets.discordToken)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: HomeViewModel(discordGateway: discordGateway))
        }
    }
}
