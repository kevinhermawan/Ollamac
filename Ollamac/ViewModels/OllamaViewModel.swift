//
//  OllamaViewModel.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 04/11/23.
//

import SwiftUI
import OllamaKit

@Observable
final class OllamaViewModel {
    private var ollamaKit: OllamaKit
    
    var models: [String] = []
    
    init(ollamaKit: OllamaKit) {
        self.ollamaKit = ollamaKit
    }
    
    func isReachable() async -> Bool {
        await ollamaKit.reachable()
    }
    
    @MainActor
    func fetch() async throws {
        let response = try await ollamaKit.models()
        
        self.models = response.models.map { $0.name }
    }
}
