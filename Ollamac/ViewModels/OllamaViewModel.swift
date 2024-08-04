//
//  OllamaViewModel.swift
//
//
//  Created by Kevin Hermawan on 13/07/24.
//

import SwiftUI
import OllamaKit

@MainActor
@Observable
final class OllamaViewModel {
    var ollamaKit: OllamaKit
    
    var models: [String] = []
    
    var loading: OllamaViewModelLoading?
    var error: OllamaViewModelError?
    
    init(ollamaKit: OllamaKit) {
        self.ollamaKit = ollamaKit
    }
    
    func fetchModels() {
        self.loading = .fetchModels
        
        Task {
            defer { self.loading = nil }
            
            do {
                let response = try await ollamaKit.models()
                
                self.models = response.models.map { $0.name }
            } catch {
                self.error = .fetchModels(error.localizedDescription)
            }
        }
    }
}

enum OllamaViewModelLoading {
    case fetchModels
}

enum OllamaViewModelError: Error {
    case fetchModels(String)
}
