//
//  AvatarImage.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 2/8/21.
//

import SwiftUI
import Combine

struct AvatarImage: View {
    @EnvironmentObject var discordGateway: DiscordAPIGateway
    @State private var image: UIImage?
    @State private var cancellables = Set<AnyCancellable>()
    
    let user: User
    
    private let width: CGFloat = 35
    private let height: CGFloat = 35
    
    var body: some View {
        imageView
            .onAppear {
                discordGateway.getAvatar(for: user)
                    .assign(to: \.image, on: self)
                    .store(in: &cancellables)
            }
    }
    
    private var imageView: some View {
        if let image = image {
            return Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: width, height: height)
                .clipShape(Circle())
                .eraseToAnyView()
        } else {
            return defaultImage.eraseToAnyView()
        }
    }
    
    private var defaultImage: some View {
        Circle()
            .foregroundColor(.gray)
            .frame(width: width, height: height)
            .overlay(firstCharacterView(from: user.username))
    }
    
    private func firstCharacterView(from string: String) -> some View {
        Text("\(String(string.prefix(1)))")
            .foregroundColor(.white)
    }
}

struct AvatarImage_Previews: PreviewProvider {
    static let imageServingMockGateway: DiscordAPIGateway = {
        var mockURLSession = MockURLSession()
        mockURLSession.mockResult = .success(#imageLiteral(resourceName: "swift-logo").pngData()!)
        
        let mockGateway = MockGateway(mockSession: mockURLSession)
        return DiscordAPIGateway(gateway: mockGateway)
    }()
    
    static var previews: some View {
        Group {
            AvatarImage(user: .mockUser)
                .environmentObject(DiscordAPIGateway.mockGateway)
            
            AvatarImage(user: User(id: "42", username: "Swift", avatar: "swift-logo"))
                .environmentObject(imageServingMockGateway)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
