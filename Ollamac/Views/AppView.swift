//
//  AppView.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 03/11/23.
//

import SwiftUI
import ViewState

struct AppView: View {
    @Environment(CommandViewModel.self) private var commandViewModel
    
    var body: some View {
        NavigationSplitView {
            ChatSidebarListView()
        } detail: {
            if let selectedChat = commandViewModel.selectedChat {
                MessageView(for: selectedChat)
            } else {
                ContentUnavailableView {
                    Text("No Chat Selected")
                }
            }
        }
    }
}
