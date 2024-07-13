//
//  AddChatView.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 04/11/23.
//

import CoreExtensions
import CoreModels
import CoreViewModels
import SwiftUI
import ViewCondition
import ViewState

struct AddChatView: View {
    private var onCreated: (_ createdChat: Chat) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @Environment(ChatViewModel.self) private var chatViewModel
    @Environment(OllamaViewModel.self) private var ollamaViewModel
    
    @State private var viewState: ViewState? = .loading
    
    @State private var name: String = "New Chat"
    @State private var selectedModel: String?
    
    init(onCreated: @escaping (_ chat: Chat) -> Void) {
        self.onCreated = onCreated
    }
    
    private var createButtonDisabled: Bool {
        if name.isEmpty { return true }
        if selectedModel.isNil { return true }
        
        return false
    }
    
    private var isLoading: Bool {
        viewState == .loading
    }
    
    private var isError: Bool {
        viewState?.errorMessage != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                        .disabled(isLoading)
                    
                    Picker("Model", selection: $selectedModel) {
                        Text("Select a model")
                            .tag(nil as String?)
                        
                        ForEach(ollamaViewModel.models, id: \.self) { model in
                            Text(model)
                                .lineLimit(1)
                                .tag(model as String?)
                        }
                    }
                    .padding(.top, 8)
                    .disabled(isLoading)
                } footer: {
                    if let errorMessage = viewState?.errorMessage {
                        HStack {
                            TextError(errorMessage)
                            
                            Button("Try Again", action: fetchAction)
                                .buttonStyle(.plain)
                                .foregroundStyle(.accent)
                                .visible(
                                    if: errorMessage == AppMessages.ollamaServerUnreachable,
                                    removeCompletely: true
                                )
                        }
                        .padding(.top, 8)
                    }
                }
            }
            .padding()
            .frame(width: 512)
            .navigationTitle("New Chat")
            .task {
                fetchAction()
            }
            .toolbar {
                ToolbarItem {
                    Text("Loading...")
                        .visible(if: isLoading, removeCompletely: true)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) { dismiss() }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create", action: createAction)
                        .disabled(createButtonDisabled)
                        .disabled(isLoading)
                }
            }
        }
    }
    
    // MARK: - Actions
    private func runIfReachable(_ function: @escaping () async -> Void) async {
        viewState = .loading
        
        if await ollamaViewModel.isReachable() {
            await function()
        } else {
            viewState = .error(message: AppMessages.ollamaServerUnreachable)
        }
    }
    
    private func fetchAction() {
        Task {
            await runIfReachable {
                do {
                    try await ollamaViewModel.fetch()
                    viewState = ollamaViewModel.models.isEmpty ? .empty : nil
                } catch {
                    viewState = .error(message: AppMessages.generalErrorMessage)
                }
            }
        }
    }
    
    private func createAction() {
        guard let model = selectedModel else { return }
        let chat = Chat(name: name, model: model)
        
        Task {
            await runIfReachable {
                do {
                    try chatViewModel.create(chat)
                    
                    onCreated(chat)
                    dismiss()
                } catch {
                    viewState = .error(message: AppMessages.generalErrorMessage)
                }
            }
        }
    }
}
