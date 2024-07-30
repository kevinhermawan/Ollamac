//
//  ChatView.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 04/11/23.
//

import ChatField
import CoreModels
import CoreViewModels
import SwiftUI
import SwiftUIIntrospect
import ViewCondition
import ViewState

struct ChatView: View {
    private var chat: Chat

    @Environment(ChatViewModel.self) private var chatViewModel
    @Environment(MessageViewModel.self) private var messageViewModel

    @Namespace private var bottomID
    @State private var isLoading = true

    @FocusState private var promptFocused: Bool
    @State private var prompt: String = ""

    init(for chat: Chat) {
        self.chat = chat
    }

    var isGenerating: Bool {
        messageViewModel.sendViewState == .loading
    }

    var body: some View {
        ScrollViewReader { scrollViewProxy in
            if isLoading {
                ProgressView()
            } else {
                List {
                    let lastMessage = messageViewModel.messages.last
                    ForEach(messageViewModel.messages) { message in
                        MessageView(message: message, isLastMessage: message == lastMessage) {
                            regenerateAction(for: message)
                        }
                    }

                    Color.clear
                        .frame(height: 0.1)
                        .id(bottomID)
                        .listRowSeparator(.hidden)
                }
                .onChange(of: messageViewModel.messages.last?.response) {
                    scrollToBottom(scrollViewProxy)
                }
                .markdownStyling()

                HStack(alignment: .bottom) {
                    ChatField("Message", text: $prompt, action: sendAction)
                        .textFieldStyle(CapsuleChatFieldStyle())
                        .focused($promptFocused)
                        .onChange(of: promptFocused) { _, newValue in
                            if newValue {
                                withAnimation(.snappy) {
                                    scrollToBottom(scrollViewProxy)
                                }
                            }
                        }

                    Button(action: sendAction) {
                        Image(systemName: "arrow.up.circle.fill")
                            .resizable()
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.plain)
                    .help("Send message")
                    .hide(if: isGenerating, removeCompletely: true)

                    Button(action: messageViewModel.stopGenerate) {
                        Image(systemName: "stop.circle.fill")
                            .resizable()
                            .frame(width: 28, height: 28)
                    }
                    .buttonStyle(.plain)
                    .help("Stop generation")
                    .visible(if: isGenerating, removeCompletely: true)
                }
                .padding(.top, 8)
                .padding(.bottom, 16)
                .padding(.horizontal)
            }
        }
        .navigationTitle(chat.name)
        .navigationSubtitle(chat.model)
        .task {
            initAction()
        }
    }

    // MARK: - Actions
    private func initAction() {
        isLoading = true
        try? messageViewModel.fetch(for: chat)

        withAnimation(.snappy) {
            isLoading = false
            promptFocused = true
        }
    }

    private func sendAction() {
        guard prompt.trimmingCharacters(in: .whitespacesAndNewlines).count > 0 else { return }

        let message = Message(prompt: prompt, response: nil)
        message.context = chat.messages.last?.context ?? []
        message.chat = chat

        Task {
            try chatViewModel.modify(chat)
            prompt = ""
            await messageViewModel.send(message)
        }
    }

    private func regenerateAction(for message: Message) {
        message.context = []
        message.response = nil

        let lastIndex = messageViewModel.messages.count - 1

        if lastIndex > 0 {
            message.context = messageViewModel.messages[lastIndex - 1].context
        }

        Task {
            try chatViewModel.modify(chat)
            await messageViewModel.regenerate(message)
        }
    }

    private func scrollToBottom(_ proxy: ScrollViewProxy) {
        guard messageViewModel.messages.count > 0 else { return }

        proxy.scrollTo(bottomID, anchor: .bottom)
    }
}
