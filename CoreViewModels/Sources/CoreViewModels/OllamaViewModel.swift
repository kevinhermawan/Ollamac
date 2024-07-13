//
//  OllamaViewModel.swift
//
//
//  Created by Kevin Hermawan on 13/07/24.
//

import SwiftUI
import OllamaKit

@Observable
public final class OllamaViewModel {
    private var ollamaKit: OllamaKit
    
    public var models: [String] = []
    
    public init(ollamaKit: OllamaKit) {
        self.ollamaKit = ollamaKit
    }
    
    public func isReachable() async -> Bool {
        await ollamaKit.reachable()
    }
    
    @MainActor
    public func fetch() async throws {
        let response = try await ollamaKit.models()
        
        self.models = response.models.map { $0.name }
    }
}
