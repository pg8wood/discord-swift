//
//  DiscordVoiceApp.swift
//  discord-voice WatchKit Extension
//
//  Created by Patrick Gatewood on 8/28/21.
//

import SwiftUI

@main
struct DiscordVoiceApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
