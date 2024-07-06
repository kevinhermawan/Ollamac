//
//  AppUpdater.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 06/07/24.
//

import Combine
import Foundation
import Sparkle

@Observable
final class AppUpdater {
    private var cancellable: AnyCancellable?
    var canCheckForUpdates = false
    
    init(_ updater: SPUUpdater) {
        cancellable = updater.publisher(for: \.canCheckForUpdates)
            .assign(to: \.canCheckForUpdates, on: self)
    }
}
