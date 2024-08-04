//
//  OllamacApp.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 03/11/23.
//

import Defaults
import OllamaKit
import SettingsModule
import Sparkle
import SwiftUI
import SwiftData

@main
struct OllamacApp: App {
    @State private var appUpdater: AppUpdater
    private var updater: SPUUpdater
    
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
                
        let ollamaURL = URL(string: Defaults[.defaultHost])!
        let ollamaKit = OllamaKit(baseURL: ollamaURL)
        
        let ollamaViewModel = OllamaViewModel(ollamaKit: ollamaKit)
        _ollamaViewModel = State(initialValue: ollamaViewModel)
        
        let messageViewModel = MessageViewModel(modelContext: modelContext, ollamaKit: ollamaKit)
        _messageViewModel = State(initialValue: messageViewModel)
        
        let chatViewModel = ChatViewModel(modelContext: modelContext)
        _chatViewModel = State(initialValue: chatViewModel)
        
        let updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
        updater = updaterController.updater
        
        let appUpdater = AppUpdater(updater)
        _appUpdater = State(initialValue: appUpdater)
    }
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(chatViewModel)
                .environment(messageViewModel)
                .environment(ollamaViewModel)
        }
        .modelContainer(sharedModelContainer)
        .commands {
            CommandGroup(replacing: .textEditing) {
                if chatViewModel.selectedChats.count > 0 {
                    SidebarContextMenu(chatViewModel: chatViewModel)
                }
            }
            
            CommandGroup(after: .appInfo) {
                Button("Check for Updates...") {
                    updater.checkForUpdates()
                }
                .disabled(appUpdater.canCheckForUpdates == false)
            }
        }
        
        Settings {
            SettingsView()
        }
    }
}
