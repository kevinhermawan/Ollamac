//
//  GeneralView.swift
//
//
//  Created by Kevin Hermawan on 13/07/24.
//

import Defaults
import OllamaKit
import SwiftUI
import ViewState

struct GeneralView: View {
    @State private var defaultHost: String = ""
    @Default(.defaultHost) private var defaultHostDefault
    
    @State private var defaultHostViewState: ViewState? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            GroupBox {
                DefaultHostTextField(defaultHost: $defaultHost, viewState: $defaultHostViewState, saveAction: saveDefaultHostAction)
            }
        }
        .onAppear {
            defaultHost = defaultHostDefault
        }
        .onDisappear {
            defaultHostViewState = nil
        }
    }
    
    func saveDefaultHostAction() {
        defaultHostViewState = .loading
        
        Task {
            let sanitizedHost = defaultHost.removeTrailingSlash()
            
            guard sanitizedHost.isValidURL(), let baseURL = URL(string: sanitizedHost) else {
                defaultHostViewState = .error(message: "The URL is invalid")
                return
            }
            
            let ollamaKit = OllamaKit(baseURL: baseURL)
            
            guard await ollamaKit.reachable() else {
                defaultHostViewState = .error(message: "The host is not reachable")
                return
            }
            
            defaultHostDefault = sanitizedHost
            defaultHostViewState = .success(message: "The default host is updated")
        }
    }
}
