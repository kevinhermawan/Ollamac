//
//  ChatView.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 8/2/24.
//

import ChatField
import SwiftUI
import ViewCondition

struct ChatView: View {
    @Environment(ChatViewModel.self) private var chatViewModel
    @Environment(MessageViewModel.self) private var messageViewModel
    
    @State private var prompt: String = ""
    @State private var scrollProxy: ScrollViewProxy? = nil
    @State private var isPreferencesPresented: Bool = false
    
    var isGenerating: Bool {
        messageViewModel.loading == .generate
    }
    
    var isNotGenerating: Bool {
        !isGenerating
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            VStack {
                List(messageViewModel.messages) { message in
                    UserMessageView(content: message.prompt)
                        .padding(.top)
                        .padding(.horizontal)
                        .listRowSeparator(.hidden)
                    
                    AssistantMessageView(content: message.response)
                        .id(message)
                        .padding(.top)
                        .padding(.horizontal)
                        .listRowSeparator(.hidden)
                        .if(messageViewModel.messages.last?.id == message.id) { view in
                            view.padding(.bottom)
                        }
                }
                
                VStack {
                    ChatField("Write your message here", text: $prompt) {
                        if isNotGenerating {
                            generateAction()
                        }
                    } trailingAccessory: {
                        Button(action: generateAction) {
                            Image(systemName: isGenerating ? "stop.fill" : "arrow.up")
                                .imageScale(.medium)
                                .padding(6)
                                .fontWeight(.bold)
                                .background(Color(nsColor: .labelColor))
                                .foregroundColor(Color(nsColor: .textBackgroundColor))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    } footer: {
                        if let activeChat = chatViewModel.activeChat, activeChat.model.isEmpty {
                            ChatFieldFooterView("You don't have any Ollama model. Please pull at least one Ollama model first.")
                                .foregroundColor(.red)
                        } else {
                            ChatFieldFooterView("AI can make mistakes. Please double-check responses.")
                        }
                    }
                    .chatFieldStyle(.capsule)
                    .font(Font.system(size: 16))
                }
                .padding(.top, 8)
                .padding(.bottom, 12)
                .padding(.horizontal)
                .visible(if: chatViewModel.activeChat.isNotNil, removeCompletely: true)
            }
            .onAppear {
                scrollProxy = proxy
            }
            .onChange(of: chatViewModel.activeChat?.id) {
                prompt = ""
                
                if let proxy = scrollProxy {
                    scrollToBottom(proxy: proxy)
                }
            }
            .onChange(of: messageViewModel.messages.last?.response) {
                if let proxy = scrollProxy {
                    scrollToBottom(proxy: proxy)
                }
            }
        }
        .navigationTitle(chatViewModel.activeChat?.name ?? "Ollamac")
        .navigationSubtitle(chatViewModel.activeChat?.model ?? "")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Show Preferences", systemImage: "sidebar.trailing") {
                    isPreferencesPresented.toggle()
                }
            }
        }
        .inspector(isPresented: $isPreferencesPresented) {
            ChatPreferencesView()
                .inspectorColumnWidth(min: 320, ideal: 320)
        }
    }
    
    private func generateAction() {
        guard let activeChat = chatViewModel.activeChat, !activeChat.model.isEmpty else { return }
        
        if isGenerating {
            messageViewModel.cancelGeneration()
        } else {
            guard let activeChat = chatViewModel.activeChat else { return }
            
            messageViewModel.generate(activeChat: activeChat, prompt: prompt)
        }
        
        prompt = ""
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard messageViewModel.messages.count > 0 else { return }
        guard let lastMessage = messageViewModel.messages.last else { return }
        
        DispatchQueue.main.async {
            proxy.scrollTo(lastMessage, anchor: .bottomTrailing)
        }
    }
}
