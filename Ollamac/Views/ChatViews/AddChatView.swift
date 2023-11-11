//
//  AddChatView.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 04/11/23.
//

import SwiftData
import SwiftUI
import ViewState

struct AddChatView: View {
    private var onCreated: (_ createdChat: Chat) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ChatViewModel.self) private var chatViewModel
    @Environment(OllamaViewModel.self) private var ollamaViewModel
    
    @State private var name: String = "New Chat"
    @State private var selectedModel: OllamaModel?
    
    @State private var errorMessage: String? = nil
    @State private var taskActionViewState: ViewState? = .loading
    
    init(onCreated: @escaping (_ chat: Chat) -> Void) {
        self.onCreated = onCreated
    }
    
    var createButtonDisabled: Bool {
        if name.isEmpty { return true }
        if selectedModel.isNil { return true }
        if let selectedModel, selectedModel.isNotAvailable { return true }
        
        return false
    }
    
    var isLoading: Bool {
        taskActionViewState == .loading
    }
    
    var isError: Bool {
        taskActionViewState == .error
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                TextField("Name", text: $name)
                    .disabled(isLoading)
                    .disabled(isError)
                
                Picker("Model", selection: $selectedModel) {
                    Text("Select a model")
                        .tag(nil as OllamaModel?)
                    
                    ForEach(ollamaViewModel.models) { model in
                        Text(model.name)
                            .lineLimit(1)
                            .tag(model as OllamaModel?)
                    }
                }
                .disabled(isLoading)
                .disabled(isError)
                
                if let selectedModel, selectedModel.isNotAvailable {
                    Text(AppMessages.ollamaModelUnavailable)
                        .foregroundStyle(.red)
                        .frame(minHeight: 32)
                }
                
                if isError, let errorMessage {
                    FormErrorView(message: errorMessage) {
                        if taskActionViewState == .error {
                            Button("Try Again") {
                                Task { await taskAction() }
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(.accent)
                        }
                    }
                }
            }
            .padding()
            .frame(width: 400)
            .navigationTitle(isLoading ? "Loading..." : "New Chat")
            .task {
                await taskAction()
            }
            .toolbar {
                if taskActionViewState == .error {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Try Again") {
                            Task { await taskAction() }
                        }
                        .buttonStyle(.borderedProminent)
                        .foregroundStyle(.accent)
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create", action: createAction)
                        .disabled(createButtonDisabled)
                        .disabled(isLoading)
                        .disabled(isError)
                }
            }
        }
    }
    
    // MARK: - Actions
    private func taskAction() async {
        taskActionViewState = .loading
        
        if await ollamaViewModel.isReachable() {
            do {
                try await ollamaViewModel.fetch()
                let isEmpty = ollamaViewModel.models.isEmpty
                
                taskActionViewState = isEmpty ? .empty : nil
            } catch {
                errorMessage = AppMessages.generalErrorMessage
                taskActionViewState = .error
            }
        } else {
            errorMessage = AppMessages.ollamaServerUnreachable
            taskActionViewState = .error
        }
    }
    
    private func createAction() {
        let chat = Chat(name: name)
        chat.model = selectedModel
        
        try? chatViewModel.create(chat)
        onCreated(chat)
        
        dismiss()
    }
}
