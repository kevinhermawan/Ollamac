//
//  OllamacApp.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 03/11/23.
//

import OllamaKit
import Sparkle
import SwiftUI
import SwiftData

@main
struct OllamacApp: App {
    private var updater: SPUUpdater
    
    @State private var updaterViewModel: UpdaterViewModel
    @State private var commandViewModel: CommandViewModel
    @State private var ollamaViewModel: OllamaViewModel
    @State private var chatViewModel: ChatViewModel
    @State private var messageViewModel: MessageViewModel
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Chat.self, Message.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
        let modelContext = sharedModelContainer.mainContext
        
        let updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
        updater = updaterController.updater
        
        let updaterViewModel = UpdaterViewModel(updater)
        _updaterViewModel = State(initialValue: updaterViewModel)
        
        let commandViewModel = CommandViewModel()
        _commandViewModel = State(initialValue: commandViewModel)
        
        let ollamaURL = URL(string: "http://localhost:11434")!
        let ollamaKit = OllamaKit(baseURL: ollamaURL)
                
        let ollamaViewModel = OllamaViewModel(ollamaKit: ollamaKit)
        _ollamaViewModel = State(initialValue: ollamaViewModel)
        
        let messageViewModel = MessageViewModel(modelContext: modelContext, ollamaKit: ollamaKit)
        _messageViewModel = State(initialValue: messageViewModel)
        
        let chatViewModel = ChatViewModel(modelContext: modelContext)
        _chatViewModel = State(initialValue: chatViewModel)
    }
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(updaterViewModel)
                .environment(commandViewModel)
                .environment(chatViewModel)
                .environment(messageViewModel)
                .environment(ollamaViewModel)
        }
        .modelContainer(sharedModelContainer)
        .commands {
            CommandGroup(after: .appInfo) {
                Button("Check for Updates...") {
                    updater.checkForUpdates()
                }
                .disabled(!updaterViewModel.canCheckForUpdates)
            }
            
            CommandGroup(replacing: .newItem) {
                Button("New Chat") {
                    commandViewModel.isAddChatViewPresented = true
                }
                .keyboardShortcut("n", modifiers: .command)
            }
            
            CommandGroup(replacing: .textEditing) {
                if let selectedChat = commandViewModel.selectedChat {
                    ChatContextMenu(commandViewModel, for: selectedChat)
                }
            }
        }
    }
}
