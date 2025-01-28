//
//  OllamacApp.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 03/11/23.
//

import Defaults
import AppInfo
import Sparkle
import SwiftUI
import SwiftData

@main
struct OllamacApp: App {
    @State private var appUpdater: AppUpdater
    private var updater: SPUUpdater
    
    @State private var chatViewModel: ChatViewModel
    @State private var messageViewModel: MessageViewModel
    @State private var codeHighlighter: CodeHighlighter

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

        let codeHighlighter =  CodeHighlighter()
        _codeHighlighter = State(initialValue: codeHighlighter)

        chatViewModel.create(model: Defaults[.defaultModel])
        guard let activeChat = chatViewModel.selectedChats
            .first else { return }
        
        chatViewModel.activeChat = activeChat
        messageViewModel.load(of: activeChat)
    }
    
    var body: some Scene {
        WindowGroup {
            AppView()
                .environment(chatViewModel)
                .environment(messageViewModel)
                .environment(codeHighlighter)
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

            CommandGroup(after: .textEditing) {
                Divider()
                Button("Increase font size", action: increaseFontSize)
                    .keyboardShortcut("+", modifiers: [.command], localization: .custom)

                Button("Decrease font size", action: decreaseFontSize)
                    .keyboardShortcut("-", modifiers: [.command], localization: .custom)
            }
        }
        
        Settings {
            SettingsView()
        }
    }

    func increaseFontSize() {
        Defaults[.fontSize] += 1
    }

    func decreaseFontSize() {
        Defaults[.fontSize] = max(Defaults[.fontSize] - 1, 8)
    }
}
