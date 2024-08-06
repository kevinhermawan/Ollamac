//
//  OllamacApp.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 03/11/23.
//

import AppInfo
import Defaults
import OllamaKit
import Sparkle
import SwiftUI
import SwiftData

@main
struct OllamacApp: App {
    @State private var appUpdater: AppUpdater
    private var updater: SPUUpdater
    
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
        self.updater = updaterController.updater
        
        let appUpdater = AppUpdater(updater)
        self._appUpdater = State(initialValue: appUpdater)
        
        let chatViewModel = ChatViewModel(modelContext: modelContext)
        self._chatViewModel = State(initialValue: chatViewModel)
        
        let messageViewModel = MessageViewModel(modelContext: modelContext)
        self._messageViewModel = State(initialValue: messageViewModel)
    }
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(chatViewModel)
                .environment(messageViewModel)
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
            
            CommandGroup(replacing: .help) {
                if let helpURL = AppInfo.value(for: "HELP_URL"), let url = URL(string: helpURL) {
                    Link("Ollamac Help", destination: url)
                }
            }
        }
        
        Settings {
            SettingsView()
        }
    }
}
