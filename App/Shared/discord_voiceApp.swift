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
    @State private var discordGateway = DiscordAPIGateway()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: HomeViewModel(discordGateway: discordGateway))
        }
    }
}
