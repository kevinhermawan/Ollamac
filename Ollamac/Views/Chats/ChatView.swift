//
//  ChatView.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 8/2/24.
//

import Defaults
import ChatField
import OllamaKit
import SwiftUI
import AppKit
import ViewCondition
import SwiftData

struct ChatView: View {
    @Environment(ChatViewModel.self) private var chatViewModel
    @Environment(MessageViewModel.self) private var messageViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(CodeHighlighter.self) private var codeHighlighter
    
    @AppStorage("experimentalCodeHighlighting") private var experimentalCodeHighlighting = false
    @Default(.fontSize) private var fontSize
    
    @State private var ollamaKit: OllamaKit
    @State private var prompt: String = ""
    @State private var scrollProxy: ScrollViewProxy? = nil
    @State private var isPreferencesPresented: Bool = false
    @State private var images: [String] = []
    @FocusState private var isFocused: Bool
    
    init() {
        let baseURL = URL(string: Defaults[.defaultHost])!
        self._ollamaKit = State(initialValue: OllamaKit(baseURL: baseURL))
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            VStack {
                List(messageViewModel.messages) { message in
                    let lastMessageId = messageViewModel.messages.last?.id
                    
                    UserMessageView(
                        content: message.prompt,
                        images: message.images,
                        copyAction: self.copyAction
                    )
                    .padding(.top)
                    .padding(.horizontal)
                    .listRowSeparator(.hidden)
                    
                    AssistantMessageView(
                        content: message.response ?? messageViewModel.tempResponse,
                        isGenerating: messageViewModel.loading == .generate,
                        isLastMessage: lastMessageId == message.id,
                        copyAction: self.copyAction,
                        regenerateAction: self.regenerateAction
                    )
                    .id(message)
                    .padding(.top)
                    .padding(.horizontal)
                    .listRowSeparator(.hidden)
                    .if(lastMessageId == message.id) { view in
                        view.padding(.bottom)
                    }
                }
                
                
            }
            .safeAreaInset(edge: .bottom, content: ChatFieldView)
            .onAppear {
                self.scrollProxy = proxy
            }
            .onChange(of: chatViewModel.activeChat?.id, initial: true) {
                self.onActiveChatChanged()
            }
            .onChange(of: messageViewModel.tempResponse) {
                if let proxy = scrollProxy {
                    scrollToBottom(proxy: proxy)
                }
            }
            .onChange(of: colorScheme, initial: true) {
                codeHighlighter.colorScheme = colorScheme
            }
            .onChange(of: fontSize, initial: true) {
                codeHighlighter.fontSize = fontSize
            }
            .onChange(of: experimentalCodeHighlighting) {
                codeHighlighter.enabled = experimentalCodeHighlighting
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
            ChatPreferencesView(ollamaKit: $ollamaKit)
                .inspectorColumnWidth(min: 320, ideal: 320)
        }
    }
    
    // MARK: Views
    
    @ViewBuilder
    private func ChatFieldView() -> some View {
        VStack {
            HStack(spacing: 8) {
                ForEach(images, id: \.self) { image in
                    if let data = Data(base64Encoded: image), let nsImage = NSImage(data: data) {
                        ZStack(alignment: .topLeading){
                            Image(nsImage: nsImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                            
                            Button(action: {
                                deleteImage(at: images.firstIndex(of: image) ?? 0)
                            }, label: {
                                Label("Remove", systemImage: "xmark.circle.fill")
                                    .labelStyle(.iconOnly)
                                    .font(.body)
                            })
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            
            ChatField("Write your message here", text: $prompt) {
                if messageViewModel.loading != .generate {
                    generateAction()
                }
            } leadingAccessory: {
                attachmentMenu
            }
            trailingAccessory: {
                CircleButton(systemImage: messageViewModel.loading == .generate ? "stop.fill" : "arrow.up", action: generateAction)
                    .disabled(prompt.isEmpty && messageViewModel.loading != .generate)
            } footer: {
                if chatViewModel.loading != nil {
                    ProgressView()
                        .controlSize(.small)
                } else if case .fetchModels(let message) = chatViewModel.error {
                    HStack {
                        Text(message)
                            .foregroundStyle(.red)
                        
                        Button("Try Again", action: onActiveChatChanged)
                            .buttonStyle(.plain)
                            .foregroundStyle(.blue)
                    }
                    .font(.callout)
                } else if messageViewModel.messages.isEmpty == false {
                    ChatFieldFooterView("\u{2318}+R to regenerate the response")
                        .foregroundColor(.secondary)
                }
//                else {
//                    ChatFieldFooterView("AI can make mistakes. Please double-check responses.")
//                        .foregroundColor(.secondary)
//                }
            }
            .chatFieldStyle(.capsule)
            .focused($isFocused)
            .font(Font.system(size: fontSize))
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .padding([.leading, .trailing], 8)
        .visible(if: chatViewModel.activeChat.isNotNil, removeCompletely: true)
    }
    
    private var attachmentMenu: some View {
        Menu {
            Button(action: attachmentAction, label: {
                Label("Upload Photo", systemImage: "photo.artframe")
            })
            
            Button(action: {}, label: {
                Label("Upload Files", systemImage: "document.fill")
            })
        } label: {
            Label("Attachment", systemImage: "plus")
                .labelStyle(.iconOnly)
        }
        .menuStyle(.borderlessButton)
        .frame(width: 32)
    }
    
    // MARK: Functions
    private func onActiveChatChanged() {
        self.prompt = ""
        if chatViewModel.shouldFocusPrompt {
            chatViewModel.shouldFocusPrompt = false
            Task {
                try await Task.sleep(for: .seconds(0.8))
                withAnimation {
                    self.isFocused = true
                }
            }
        }
        
        if let activeChat = chatViewModel.activeChat, let host = activeChat.host, let baseURL = URL(string: host) {
            self.ollamaKit = OllamaKit(baseURL: baseURL)
            self.chatViewModel.fetchModels(self.ollamaKit)
        }
    }
    
    private func copyAction(_ content: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(content, forType: .string)
    }
    
    private func generateAction() {
        guard let activeChat = chatViewModel.activeChat, !activeChat.model.isEmpty, chatViewModel.isHostReachable else { return }
        
        if messageViewModel.loading == .generate {
            messageViewModel.cancelGeneration()
        } else {
            let prompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !prompt.isEmpty else {
                self.prompt = ""
                return
            }
            
            guard let activeChat = chatViewModel.activeChat else { return }
            messageViewModel.generate(ollamaKit, activeChat: activeChat, prompt: prompt, images: images)
        }
        
        self.images = []
        self.prompt = ""
    }
    
    private func attachmentAction() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.image, .png, .jpeg, .gif]
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        
        if panel.runModal() == .OK {
            for url in panel.urls {
                if let imageData = try? Data(contentsOf: url) {
                    let processedImage = processImage(imageData: imageData)
                    guard let base64 = processedImage else {
                        return
                    }
                    images.append(base64)
                }
            }
        }
    }
    
    private func deleteImage(at index: Int) {
        guard index >= 0 && index < images.count else { return }
        images.remove(at: index)
    }
    
    private func processImage(imageData: Data, maxSize: CGFloat = 512) -> String? {
        guard let originalImage = NSImage(data: imageData) else {return nil}
        
        let resizedImage = resizeImage(originalImage, maxSize: maxSize)
        
        // Convert to JPEG data
        guard let tiffData = resizedImage?.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData) else {
            return nil
        }
        guard let jpegData = bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.8]) else {
            print("Failed to convert to JPEG")
            return nil
        }
        
        return jpegData.base64EncodedString()
    }
    
    func resizeImage(_ image: NSImage, maxSize: CGFloat) -> NSImage? {
        
        let originalSize = image.size
        let ratio = min(maxSize / originalSize.width, maxSize / originalSize.height)
        
        let newSize = NSSize(width: originalSize.width * ratio, height: originalSize.height * ratio)
        let newImage = NSImage(size: newSize)
        
        newImage.lockFocus()
        image.draw(in: NSRect(origin: .zero, size: newSize),
                   from: NSRect(origin: .zero, size: originalSize),
                   operation: .copy,
                   fraction: 1.0)
        newImage.unlockFocus()
        
        return newImage
    }
    
    private func regenerateAction() {
        guard let activeChat = chatViewModel.activeChat, !activeChat.model.isEmpty, chatViewModel.isHostReachable else { return }
        
        if messageViewModel.loading == .generate {
            messageViewModel.cancelGeneration()
        } else {
            guard let activeChat = chatViewModel.activeChat else { return }
            
            messageViewModel.regenerate(ollamaKit, activeChat: activeChat, images: images)
        }
        
        prompt = ""
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard messageViewModel.messages.count > 0 else { return }
        guard let lastMessage = messageViewModel.messages.last else { return }
        
        DispatchQueue.main.async {
            proxy.scrollTo(lastMessage, anchor: .bottom)
        }
    }
}
