//
//  AppView.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 03/11/23.
//

import SwiftUI

struct AppView: View {
    var body: some View {
        NavigationSplitView {
            SidebarView()
                .navigationSplitViewColumnWidth(min: 256, ideal: 256)
        } detail: {
            ChatView()
        }
    }
}
