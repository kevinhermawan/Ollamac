//
//  SidebarListItemView.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 8/2/24.
//

import SwiftUI

struct SidebarListItemView: View {
    private let chatViewModel: ChatViewModel
    private let name: String
    private let message: String?
    
    init(chatViewModel: ChatViewModel, name: String, message: String?) {
        self.chatViewModel = chatViewModel
        self.name = name
        self.message = message
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(name)
                .font(.headline.weight(.semibold))
            
            if let message {
                Text(message)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .contextMenu {
            SidebarContextMenu(chatViewModel: chatViewModel)
        }
    }
}
