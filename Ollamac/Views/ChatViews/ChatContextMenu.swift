//
//  ChatContextMenu.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 06/11/23.
//

import CoreModels
import CoreViewModels
import SwiftUI

struct ChatContextMenu: View {
    private var viewModel: CommandViewModel
    private var chat: Chat
    
    init(_ viewModel: CommandViewModel, for chat: Chat) {
        self.viewModel = viewModel
        self.chat = chat
    }
    
    var body: some View {
        Button("Rename \"\(chat.name)\"") {
            viewModel.chatToRename = chat
        }
        .keyboardShortcut("r", modifiers: [.command])
        
        Divider()
        
        Button("Delete \"\(chat.name)\"") {
            viewModel.chatToDelete = chat
        }
        .keyboardShortcut(.delete, modifiers: [.shift, .command])
    }
}
