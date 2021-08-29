//
//  View+Extensions.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 11/28/20.
//

import SwiftUI

extension View {
    @available(iOS, deprecated, message: "I have learned about the perils of AnyView")
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}
