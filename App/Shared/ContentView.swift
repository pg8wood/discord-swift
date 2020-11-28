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
            .sink(receiveValue: { [weak self] event in
                self?.events.append(event)
            })
            .store(in: &cancellables)
    }
}

struct ContentView: View {
    @State private var isShowingEventLogSheet: Bool = false
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
        ZStack {
            
            // TODO make this not bad
            VStack {
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
            
            connectionStatusView
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
////        ContentView(isLoading: .constant(true))
//    }
//}
