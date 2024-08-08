//
//  SidebarToolbarContent.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 8/2/24.
//

import SwiftUI

struct SidebarToolbarContent: ToolbarContent {
    private let addAction: () -> Void
    
    init(addAction: @escaping () -> Void) {
        self.addAction = addAction
    }
    
    var body: some ToolbarContent {
        ToolbarItemGroup {
            Spacer()
            
            Button(action: addAction) {
                Label("New Chat", systemImage: "square.and.pencil")
            }
            .help("New Chat")
        }
    }
}
