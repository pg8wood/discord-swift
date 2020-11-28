//
//  ContentState.swift
//  DiscordVoice
//
//  Created by Patrick Gatewood on 11/28/20.
//

import Foundation

enum ContentState<T, ErrorType: Error> {
    case notLoaded
    case loading
    case loaded(T)
    case error(ErrorType)
}
