//
//  GeneralView.swift
//
//
//  Created by Kevin Hermawan on 13/07/24.
//

import Defaults
import SwiftUI

struct GeneralView: View {
    @Default(.defaultHost) private var defaultHost
    @Default(.defaultSystemPrompt) private var defaultSystemPrompt
    
    @State private var isUpdateOllamaHostPresented = false
    @State private var isUpdateSystemPromptPresented = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            GeneralBox(label: "Default Ollama Host", value: defaultHost) {
                isUpdateOllamaHostPresented = true
            }
            
            GeneralBox(label: "Default System Prompt", value: defaultSystemPrompt) {
                isUpdateSystemPromptPresented = true
            }
        }
        .sheet(isPresented: $isUpdateOllamaHostPresented) {
            UpdateOllamaHostSheet(host: defaultHost) { host in
                self.defaultHost = host
            }
        }
        .sheet(isPresented: $isUpdateSystemPromptPresented) {
            UpdateSystemPromptSheet(prompt: defaultSystemPrompt) { prompt in
                self.defaultSystemPrompt = prompt
            }
        }
    }
}
