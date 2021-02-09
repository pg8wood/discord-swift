//
//  EventListView.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 11/28/20.
//

import SwiftUI


// TODO: should the gateway just publish state of incoming json instead of reencoding here??
enum DiscordEventEncoder {
    private static let errorDictionary: [String: Any] =
        ["invalid codable": "contents unknown"]
    
    static func encodeToDictionary(_ event: Event) -> [String: Any] {
        do {
            let data: Data
            
            // TODO: should the gateway just publish state of incoming json instead of reencoding here.
            switch event {
            case .dispatch(let event):
                switch event {
                case .ready(let readyEvent):
                    data = try JSONEncoder().encode(readyEvent)
                case .guildCreate(let guildCreateEvent):
                    data = try JSONEncoder().encode(guildCreateEvent)
                case .guildUpdate(let guildUpdateEvent):
                    data = try JSONEncoder().encode(guildUpdateEvent)
                case .voiceStateUpdate(let guildUpdateEvent):
                    data = try JSONEncoder().encode(guildUpdateEvent)
                case .guildMembersChunk(let guildMembersChunk):
                    data = try JSONEncoder().encode(guildMembersChunk)
                case .unknown(let string):
                    data = string.data(using: .utf8) ?? Data()
                }
            case .hello(let helloEvent):
                data = try JSONEncoder().encode(helloEvent)
            }
            
            let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
            
            return dictionary ?? errorDictionary
        } catch {
            return errorDictionary
        }
    }
}

struct EventListView: View {
    @Binding var events: [Event]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(events.reversed(), id: \.self) { event in
                    eventListItem(from: event)
                }
            }
            .navigationTitle("Received Events")
        }
    }
    
    private func eventListItem(from event: Event) -> some View {
        let jsonInspectionView = JSONInspectionView(jsonDict: DiscordEventEncoder.encodeToDictionary(event))
            .navigationTitle(event.name)
            .edgesIgnoringSafeArea(.bottom)
        
        return NavigationLink(destination: jsonInspectionView) {
            Text(event.name)
        }
    }
}

//struct EventList_Previews: PreviewProvider {
//    static var previews: some View {
//        let user = User(id: 42, username: "Luke Skywalker")
//        let readyPayload = ReadyPayload(gatewayVersion: 0, user: user, sessionID: 12)
//        let event: DiscordEvent = .ready(readyPayload)
//        let viewModel =
//        
//        EventList(
//        )
//    }
//}
