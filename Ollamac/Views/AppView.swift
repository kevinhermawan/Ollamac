//
//  AppView.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 03/11/23.
//

import CoreViewModels
import SwiftUI
import ViewState

struct AppView: View {
    @Environment(CommandViewModel.self) private var commandViewModel
    
    var body: some View {
        NavigationSplitView {
            ChatSidebarListView()
                .navigationSplitViewColumnWidth(min: 240, ideal: 240)
        } detail: {
            if let selectedChat = commandViewModel.selectedChat {
                ChatView(for: selectedChat)
                    .id(selectedChat.id)
            } else {
                ContentUnavailableView {
                    Text("No Chat Selected")
                }
            }
        }
    }
}
