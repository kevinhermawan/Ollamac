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
    
    var body: some View {
        ScrollViewReader { proxy in
            List(messageViewModel.messages) { message in
                UserMessageView(content: message.prompt)
                    .padding(.top)
                    .padding(.horizontal)
                    .listRowSeparator(.hidden)
                
                AssistantMessageView(content: message.response)
                    .padding(.top)
                    .padding(.horizontal)
                    .listRowSeparator(.hidden)
                    .id(message)
            }
            .onAppear {
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: messageViewModel.messages) {
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: messageViewModel.messages.last?.response) {
                scrollToBottom(proxy: proxy)
            }
            
            VStack {
                ChatField("Write your message here", text: $prompt) {
                    generateAction()
                } trailingAccessory: {
                    Button(action: generateAction) {
                        Image(systemName: messageViewModel.isGenerating ? "stop.fill" : "arrow.up")
                            .imageScale(.medium)
                            .padding(6)
                            .fontWeight(.bold)
                            .background(Color(nsColor: .labelColor))
                            .foregroundColor(Color(nsColor: .textBackgroundColor))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                } footer: {
                    Text("AI can make mistakes. Please double-check responses.")
                        .padding(.top, 4)
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
                .chatFieldStyle(.capsule)
                .font(Font.system(size: 16))
            }
            .padding(.top, 8)
            .padding(.bottom, 12)
            .padding(.horizontal)
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
        .onChange(of: chatViewModel.activeChat) {
            prompt = ""
        }
    }
    
    private func generateAction() {
        if messageViewModel.isGenerating {
            messageViewModel.cancelGeneration()
        } else {
            guard let activeChat = chatViewModel.activeChat else { return }
            
            messageViewModel.generate(activeChat: activeChat, prompt: prompt)
        }
        
        prompt = ""
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard messageViewModel.messages.count > 0 else { return }
        let lastIndex = messageViewModel.messages.count - 1
        let lastMessage = messageViewModel.messages[lastIndex]
        
        proxy.scrollTo(lastMessage, anchor: .bottom)
    }
}
