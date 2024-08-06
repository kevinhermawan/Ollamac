//
//  UpdateOllamaHostSheet.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 8/7/24.
//

import OllamaKit
import SwiftUI
import ViewState

struct UpdateOllamaHostSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var viewState: ViewState?
    @State private var host: String
    
    private let action: (_ host: String) -> Void
    
    init(host: String, action: @escaping (_ host: String) -> Void) {
        self.host = host
        self.action = action
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Enter the Ollama host", text: $host)
                        .labelsHidden()
                } footer: {
                    Text(String(stringLiteral: "Enter the Ollama host (e.g., http://localhost:11434)"))
                        .foregroundStyle(.secondary)
                        .whenError(viewState) { message in
                            Text(message)
                                .foregroundStyle(.red)
                        }
                        .padding(.top, 4)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 10)
            .navigationTitle("Update Ollama Host")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel, action: { dismiss() })
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: saveAction)
                        .disabled(viewState == .loading)
                }
            }
        }
    }
    
    @MainActor
    func saveAction() {
        viewState = .loading
        
        Task {
            let sanitizedHost = host.removeTrailingSlash()
            
            guard sanitizedHost.isValidURL(), let baseURL = URL(string: sanitizedHost) else {
                viewState = .error(message: "The URL is invalid")
                return
            }
            
            let ollamaKit = OllamaKit(baseURL: baseURL)
            
            guard await ollamaKit.reachable() else {
                viewState = .error(message: "The Ollama host is not reachable")
                return
            }
            
            action(sanitizedHost)
            dismiss()
        }
    }
}
