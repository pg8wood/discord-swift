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
    @Published var events: [Event] = []
    @Published var test: Int = 2
    
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
                
                if case .dispatch(.guildCreate(let guild)) = event {
                    if !self.guilds.contains(guild) {
                        self.guilds.append(guild)
                    }
                }
            })
            .store(in: &cancellables)
    }
    
    func send(command: Command) {
        gateway.send(command: command)
    }
}

struct ContentView: View {
    @State private var isShowingEventLogSheet: Bool = false
    @State private var isShowingErrorAlert: Bool = false
    @State private var selectedGuild: GuildPayload?
    @ObservedObject var viewModel: HomeViewModel
    
    private var errorAlert: Alert {
        if case .error(let error) = viewModel.contentState {
            return Alert(title: Text("Gateway Error"), message: Text(error.localizedDescription), dismissButton: .default(Text("Heck")))
        } else {
            return Alert(title: Text("Unknown error"), message: nil, dismissButton: .default(Text("Heck")))
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                Text("test: \($viewModel.test.wrappedValue)")
                ConnectionStatusView(contentState: $viewModel.contentState)
                
                Spacer()
                
                GuildPreviewScrollView(guilds: $viewModel.guilds)
                    .alert(isPresented: $isShowingErrorAlert) {
                        errorAlert
                    }
                    .onReceive(viewModel.$contentState) { contentState in
                        if case .error = contentState {
                            isShowingErrorAlert = true
                        }
                    }
                //            ActiveVoiceChatMemberList(guild: $selectedGuild)
                
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
            
            ForEach(viewModel.events, id: \.self) { event in
                ToastView(text: event.name)
            
            }
        }
        .padding()
    }
}

struct MockAPIClient: APIClient {
    func get<T>(_ request: T) -> AnyPublisher<T.Response, APIError> where T : APIRequest {
        PassthroughSubject<T.Response, APIError>().eraseToAnyPublisher()
    }
}

struct MockGateway: WebSocketGateway {
    var session: URLSession
    
    var discordAPI: APIClient
    
    var eventPublisher: AnyPublisher<Event, Never>
    
    init() {
        session = .shared // TODO use a mock one
        discordAPI = MockAPIClient()
        eventPublisher = PassthroughSubject<Event, Never>().eraseToAnyPublisher()
    }
    
    func connect() -> AnyPublisher<ReadyPayload, GatewayError> {
        PassthroughSubject<ReadyPayload, GatewayError>().eraseToAnyPublisher()
    }
    
    func send(command: Command) {
        // TODO
    }
}

class MockHomeViewModel: HomeViewModel {
    init(_ contentState: ContentState<ReadyPayload, GatewayError>) {
        super.init(gateway: MockGateway())
        self.contentState = contentState
    }
    
    convenience init(_ contentState: ContentState<ReadyPayload, GatewayError>, guilds: [GuildPayload]) {
        self.init(contentState)
        self.guilds = guilds
    }
}


struct ContentView_Previews: PreviewProvider {
    private static var mockUser: User {
        User(id: "42", username: "Luke Skywalker")
    }
    
    private static var mockReadyPayload: ReadyPayload {
        ReadyPayload(gatewayVersion: 42, user: mockUser, sessionID: "")
    }
    
    private static var mockGuilds: [GuildPayload] {
        (1...4).map {
            GuildPayload(id: "42", name: "Test guild \($0)", icon: "", voiceStates: [], members: [])
        }
    }
    
    static var previews: some View {
        Group {
            ContentView(viewModel: MockHomeViewModel(.notLoaded))
            ContentView(viewModel: MockHomeViewModel(.loading))
            ContentView(viewModel: MockHomeViewModel(.loaded(mockReadyPayload), guilds: mockGuilds))
            ContentView(viewModel: MockHomeViewModel(.error(.decodingFailed)))
        }
    }
}
