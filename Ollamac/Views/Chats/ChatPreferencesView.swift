//
//  ChatPreferencesView.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 8/4/24.
//

import Defaults
import OllamaKit
import SwiftUI
import SwiftUIIntrospect

struct ChatPreferencesView: View {
    @Environment(ChatViewModel.self) private var chatViewModel
    
    @Binding private var ollamaKit: OllamaKit
    
    @State private var isUpdateOllamaHostPresented: Bool = false
    @State private var isUpdateSystemPromptPresented: Bool = false
    
    @Default(.defaultModel) private var model: String
    @State private var host: String
    @State private var systemPrompt: String
    @State private var temperature: Double
    @State private var topP: Double
    @State private var topK: Int
    
    init(ollamaKit: Binding<OllamaKit>) {
        self._ollamaKit = ollamaKit
        
        self.host = Defaults[.defaultHost]
        self.systemPrompt = Defaults[.defaultSystemPrompt]
        self.temperature = Defaults[.defaultTemperature]
        self.topP = Defaults[.defaultTopP]
        self.topK = Defaults[.defaultTopK]
    }
    
    var body: some View {
        Form {
            Section {
                Picker("Selected Model", selection: $model) {
                    ForEach(chatViewModel.models, id: \.self) { model in
                        Text(model).tag(model)
                    }
                }
            } header: {
                HStack {
                    Text("Model")
                    
                    Spacer()
                    
                    Button(action: { chatViewModel.fetchModels(ollamaKit) }) {
                        if chatViewModel.loading == .fetchModels {
                            ProgressView()
                                .controlSize(.small)
                        } else {
                            Text("Refresh")
                                .foregroundColor(.accent)
                        }
                    }
                    .buttonStyle(.accessoryBar)
                    .disabled(chatViewModel.loading == .fetchModels)
                }
            }
            .onChange(of: model) { _, newValue in
                self.chatViewModel.activeChat?.model = newValue
            }
            
            Section {
                Text(host)
                    .help(host)
                    .lineLimit(1)
            } header: {
                HStack {
                    Text("Host")
                    
                    Spacer()
                    
                    Button("Change", action: { isUpdateOllamaHostPresented = true })
                        .buttonStyle(.accessoryBar)
                        .foregroundColor(.accent)
                }
            }
            .onChange(of: host) { _, newValue in
                self.chatViewModel.activeChat?.host = newValue
                
                if let baseURL = URL(string: newValue) {
                    self.ollamaKit = OllamaKit(baseURL: baseURL)
                }
            }
            
            Section {
                Text(systemPrompt)
                    .help(systemPrompt)
                    .lineLimit(3)
            } header: {
                HStack {
                    Text("System Prompt")
                    
                    Spacer()
                    
                    Button("Change", action: { isUpdateSystemPromptPresented = true })
                        .buttonStyle(.accessoryBar)
                        .foregroundColor(.accent)
                }
            }
            .onChange(of: systemPrompt) { _, newValue in
                self.chatViewModel.activeChat?.systemPrompt = newValue
            }
            
            Section {
                Slider(value: $temperature, in: 0...1, step: 0.1) {
                    Text(temperature.formatted())
                } minimumValueLabel: {
                    Text("0")
                } maximumValueLabel: {
                    Text("1")
                }
            } header: {
                Text("Temperature")
            } footer: {
                ChatPreferencesFooterView("Controls randomness. Higher values increase creativity, lower values are more focused.")
            }
            .onChange(of: temperature) { _, newValue in
                self.chatViewModel.activeChat?.temperature = newValue
            }
            
            Section {
                Slider(value: $topP, in: 0...1, step: 0.1) {
                    Text(topP.formatted())
                } minimumValueLabel: {
                    Text("0")
                } maximumValueLabel: {
                    Text("1")
                }
            } header: {
                Text("Top P")
            } footer: {
                ChatPreferencesFooterView("Affects diversity. Higher values increase variety, lower values are more conservative.")
            }
            .onChange(of: topP) { _, newValue in
                self.chatViewModel.activeChat?.topP = newValue
            }
            
            Section {
                Stepper(topK.formatted(), value: $topK)
            } header: {
                Text("Top K")
            } footer: {
                ChatPreferencesFooterView("Limits token pool. Higher values increase diversity, lower values are more focused.")
            }
            .onChange(of: topK) { _, newValue in
                self.chatViewModel.activeChat?.topK = newValue
            }
        }
        .onChange(of: self.chatViewModel.activeChat) { _, newValue in
            if let model = newValue?.model {
                self.model = model
            }
            
            if let host = newValue?.host {
                self.host = host
            }
            
            if let systemPrompt = newValue?.systemPrompt {
                self.systemPrompt = systemPrompt
            }
            
            if let temperature = newValue?.temperature {
                self.temperature = temperature
            }
            
            if let topP = newValue?.topP {
                self.topP = topP
            }
            
            if let topK = newValue?.topK {
                self.topK = topK
            }
        }
        .sheet(isPresented: $isUpdateOllamaHostPresented) {
            UpdateOllamaHostSheet(host: host) { host in
                self.host = host
            }
        }
        .sheet(isPresented: $isUpdateSystemPromptPresented) {
            UpdateSystemPromptSheet(prompt: systemPrompt) { prompt in
                self.systemPrompt = prompt
            }
        }
    }
}
