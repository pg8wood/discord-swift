//
//  ContentView.swift
//  Shared
//
//  Created by Patrick Gatewood on 11/27/20.
//

import SwiftUI
import Combine

class HomeViewModel: ObservableObject {
    @Published var contentState: ContentState<ReadyPayload, GatewayError> = .notLoaded
    @Published var guilds: [GuildPayload] = []
    @Published var events: [DiscordEvent] = []
    
    private let gateway: WebSocketGateway
    
    private var cancellables = Set<AnyCancellable>()
    
    init(gateway: WebSocketGateway) {
        self.gateway = gateway
        connectToGateway()
    }
    
    private func connectToGateway() {
        gateway.connect()
            .handleEvents(receiveSubscription: { [weak self] _ in
                self?.contentState = .loading
            })
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                
                switch completion {
                case .failure(let error):
                    self.contentState = .error(error)
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] readyPayload in
                self?.contentState = .loaded(readyPayload)
            })
            .store(in: &cancellables)
        
        gateway.eventPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] event in
                guard let self = self else { return }
                
                self.events.append(event)
                
                if case .guildCreate(let guild) = event {
                    if !self.guilds.contains(guild) {
                        self.guilds.append(guild)
                    }
                }
            })
            .store(in: &cancellables)
    }
}

struct ContentView: View {
    @State private var isShowingEventLogSheet: Bool = false
    @State private var selectedGuild: GuildPayload?
    @ObservedObject var viewModel: HomeViewModel
    
    var connectionStatusView: AnyView {
        switch viewModel.contentState {
        case .notLoaded:
            return Text("Hello, World!")
                .eraseToAnyView()
        case .loading:
            return ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .eraseToAnyView()
        case .loaded(let readyPayload):
            return
                Text("Hello, \(readyPayload.user.username)! Discord is connected.")
                .eraseToAnyView()
        case .error(let error):
            return
                Text("An error occurred: \(error.localizedDescription)")
                .eraseToAnyView()
        }
    }
    
    var body: some View {
        VStack {
            connectionStatusView
            
            Spacer()

            Text("Guilds")
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 1)) {
                ForEach(viewModel.guilds, id: \.self) { guild in
                    Button {
                        selectedGuild = guild
                    } label: {
                        Text(guild.name)
                    }
                   
                }
            }
            
            Spacer()
            
            Text("Members in voice:")
            ActiveVoiceChatMemberList(guild: $selectedGuild)
            
            Spacer()
            
            Button {
                isShowingEventLogSheet = true
            } label: {
                Text("View Events")
            }
            .sheet(isPresented: $isShowingEventLogSheet) {
                EventListView(events: $viewModel.events)
            }
        }
        .padding()
    }
}

struct ActiveVoiceChatMemberList: View {
    @Binding var guild: GuildPayload?
    
    var body: some View {
        guard let guild = guild else {
            return EmptyView().eraseToAnyView()
        }
        
        return HStack {
            ForEach(guild.usersInVoiceChat, id: \.self) { user in
                Text(user.username)
            }
        }
        .eraseToAnyView()
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
////        ContentView(isLoading: .constant(true))
//    }
//}
