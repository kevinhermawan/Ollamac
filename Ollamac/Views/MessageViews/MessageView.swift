//
//  MessageView.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 04/11/23.
//

import OptionalKit
import SwiftUI
import SwiftUIIntrospect
import ViewCondition
import ViewState

struct MessageView: View {
    private var chat: Chat
    
    @Environment(\.modelContext) private var modelContext
    @Environment(ChatViewModel.self) private var chatViewModel
    @Environment(MessageViewModel.self) private var messageViewModel
    @Environment(OllamaViewModel.self) private var ollamaViewModel
    
    @FocusState private var isEditorFocused: Bool
    @State private var isEditorExpanded: Bool = false
    
    @State private var errorMessage: String? = nil
    @State private var prompt: String = ""
    
    init(for chat: Chat) {
        self.chat = chat
    }
    
    var isGenerating: Bool {
        messageViewModel.sendViewState == .loading
    }
    
    var promptInputDisabled: Bool {
        if isGenerating { return true }
        if let model = chat.model, model.isNotAvailable { return true }
        
        return false
    }
    
    var sendButtonDisabled: Bool {
        if prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return true }
        if isGenerating { return true }
        if let model = chat.model, model.isNotAvailable { return true }
        
        return false
    }
    
    var body: some View {
        ScrollViewReader { scrollViewProxy in
            List(messageViewModel.messages) { message in
                MessageListItemView(
                    message.prompt ?? "",
                    isAssistant: false
                )
                
                MessageListItemView(
                    message.response ?? "",
                    isAssistant: true,
                    isGenerating: message.response.isNil && isGenerating
                )
                .id(message)
            }
            .onAppear {
                scrollToBottom(scrollViewProxy)
            }
            .onChange(of: messageViewModel.messages) {
                scrollToBottom(scrollViewProxy)
            }
            .onChange(of: messageViewModel.messages.last?.response?.count) {
                scrollToBottom(scrollViewProxy)
            }
            
            VStack(spacing: 8) {
                HStack(alignment: .bottom, spacing: 16) {
                    PromptEditor(prompt: $prompt)
                        .frame(minHeight: 32, maxHeight: 256)
                        .fixedSize(horizontal: false, vertical: true)
                        .overlay(alignment: .topTrailing) {
                            Button(action: { isEditorExpanded = true }) {
                                Label("Expand", systemImage: "arrow.up.left.and.arrow.down.right")
                                    .labelStyle(.iconOnly)
                            }
                            .padding(8)
                            .buttonStyle(.plain)
                            .keyboardShortcut("e", modifiers: .command)
                            .help("Expand editor (⌘ + E)")
                        }
                        .focused($isEditorFocused)
                        .disabled(promptInputDisabled)
                        .onChange(of: messageViewModel.sendViewState) {
                            isEditorFocused = messageViewModel.sendViewState.isNil
                        }
                        .onChange(of: prompt) {
                            directSendAction()
                        }
                    
                    Button(action: sendAction) {
                        Label("Send", systemImage: "paperplane")
                            .padding(8)
                            .foregroundStyle(.white)
                            .help("Send message (Return)")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(sendButtonDisabled)
                }
                .padding(.horizontal)
                
                if let errorMessage {
                    HStack(alignment: .center) {
                        Text(errorMessage)
                    }
                    .foregroundStyle(.red)
                }
                
                if messageViewModel.sendViewState == .error {
                    HStack(alignment: .center) {
                        Text(AppMessages.generalErrorMessage)
                    }
                    .foregroundStyle(.red)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 16)
            .hide(if: isEditorExpanded, removeCompletely: true)
        }
        .navigationTitle(chat.name)
        .navigationSubtitle(chat.model?.name ?? "")
        .task {
            initAction()
        }
        .onChange(of: chat) {
            initAction()
        }
        .sheet(isPresented: $isEditorExpanded) {
            PromptEditorExpandedView(prompt: $prompt) {
                sendAction()
            }
            .onDisappear {
                isEditorFocused = true
            }
        }
    }
    
    // MARK: - Actions
    private func initAction() {
        try? messageViewModel.fetch(for: chat)
        
        isEditorFocused = true
    }
    
    private func sendAction() {
        try? chatViewModel.modify(chat)
        
        let message = Message(prompt: prompt, response: nil)
        message.context = messageViewModel.messages.last?.context ?? []
        message.chat = chat
        
        Task {
            await messageViewModel.send(message)
            
            if await ollamaViewModel.isReachable() {
                errorMessage = nil
                prompt = ""
            } else {
                errorMessage = AppMessages.ollamaServerUnreachable
                messageViewModel.revertSend(message)
            }
        }
    }
    
    private func directSendAction() {
        let trimmedPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        let isLastCharacterNewline = prompt.unicodeScalars.last
            .map { CharacterSet.newlines.contains($0) } ?? false
        
        guard !trimmedPrompt.isEmpty && isLastCharacterNewline else { return }
        
        sendAction()
    }
    
    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        guard messageViewModel.messages.count > 0 else { return }
        let lastIndex = messageViewModel.messages.count - 1
        let lastMessage = messageViewModel.messages[lastIndex]
        
        proxy.scrollTo(lastMessage, anchor: .bottom)
    }
}
