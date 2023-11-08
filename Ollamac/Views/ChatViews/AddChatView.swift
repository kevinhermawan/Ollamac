//
//  AddChatView.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 04/11/23.
//

import OptionalKit
import SwiftData
import SwiftUI
import ViewCondition

struct AddChatView: View {
    private var onCreated: (_ createdChat: Chat) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ChatViewModel.self) private var chatViewModel
    @Environment(OllamaViewModel.self) private var ollamaViewModel
    
    @State private var name: String = ""
    @State private var selectedModel: OllamaModel?
    
    init(onCreated: @escaping (_ chat: Chat) -> Void) {
        self.onCreated = onCreated
    }
    
    var disabledDoneButton: Bool {
        if name.isEmpty { return true }
        if selectedModel.isNil { return true }
        if let selectedModel, selectedModel.isNotAvailable { return true }
        if ollamaViewModel.checkConnectionViewState == .error { return true }

        return false
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                TextField("Name", text: $name)
                
                Picker("Model", selection: $selectedModel) {
                    Text("Select a model")
                        .tag(nil as OllamaModel?)
                    
                    ForEach(ollamaViewModel.models) { model in
                        Text(model.name)
                            .lineLimit(1)
                            .tag(model as OllamaModel?)
                    }
                }
                
                if let selectedModel, selectedModel.isNotAvailable {
                    Text(Constants.modelNotAvailableErrorMessage)
                        .foregroundStyle(.secondary)
                        .frame(minHeight: 32)
                }
                
                if ollamaViewModel.checkConnectionViewState == .error {
                    Text(Constants.ollamaConnectionErrorMessage)
                        .foregroundStyle(.secondary)
                        .frame(minHeight: 32)
                }

            }
            .padding()
            .frame(width: 350)
            .navigationTitle("New Chat")
            .task {
                await ollamaViewModel.checkConnection()
                await ollamaViewModel.fetch()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        let chat = Chat(name: name)
                        chat.model = selectedModel
                        chatViewModel.create(chat)
                        
                        onCreated(chat)
                        dismiss()
                    }
                    .disabled(disabledDoneButton)
                }
            }
        }
    }
}

#Preview {
    AddChatView() { createdChat in }
        .modelContainer(for: AppModel.all, inMemory: true)
}
