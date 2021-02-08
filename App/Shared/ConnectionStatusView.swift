//
//  ConnectionStatusView.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 12/11/20.
//

import SwiftUI

struct ConnectionStatusView: View {
    @Binding var contentState: ContentState<ReadyPayload, GatewayError>
    @State private var scale: CGFloat = 1
    
    private var placeholder: some View {
        Text("This is placeholder text. Don't read it!")
            .redacted(reason: .placeholder)
    }
    
    var body: some View {
        switch contentState {
        case .notLoaded:
            placeholder
        case .loading:
            placeholder
                .scaleEffect(scale)
                .onAppear(perform: animateLoadingState)
        case .loaded(let readyPayload):
            Text("Hello, ") + Text("\(readyPayload.user.username)").bold() + Text("! Discord is connected.")
        case .error(let error):
            Text("⚠️ \(error.localizedDescription)")
        }
    }
    
    private func animateLoadingState() {
        var scaleAnimation: Animation {
            Animation
                .easeInOut(duration: 1)
                .repeatForever(autoreverses: true)
        }
        
        withAnimation(scaleAnimation) {
            self.scale = 1.05
        }
    }
}

struct ConnectionStatusView_Previews: PreviewProvider {
    static private var mockReadyPayload: ReadyPayload {
        ReadyPayload(gatewayVersion: 42,
                     user: User(id: "test", username: "test user", avatar: "test"),
                     sessionID: "mock session")
    }
    
    static var previews: some View {
        Group {
            ConnectionStatusView(contentState: .constant(.notLoaded))
            ConnectionStatusView(contentState: .constant(.loading))
            ConnectionStatusView(contentState: .constant(.loaded(mockReadyPayload)))
            ConnectionStatusView(contentState: .constant(.error(GatewayError.initialConnectionFailed)))
        }
        .previewLayout(.sizeThatFits)
    }
}
