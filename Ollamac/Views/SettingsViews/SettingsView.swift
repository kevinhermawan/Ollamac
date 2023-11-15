//
//  SettingsView.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 14/11/23.
//

import SwiftUI

fileprivate enum SettingsTab: String {
    case models
    
    var title: String {
        switch self {
        case .models:
            return "Models"
        }
    }
    
    var systemImage: String {
        switch self {
        case .models:
            return "cube"
        }
    }
}

struct SettingsView: View {
    private var ollamaViewModel: OllamaViewModel
    
    @State private var selectedTab: SettingsTab = .models
    
    init(ollamaViewModel: OllamaViewModel) {
        self.ollamaViewModel = ollamaViewModel
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            SettingsModelsView(ollamaViewModel: ollamaViewModel)
                .tabItem {
                    Label(SettingsTab.models.title, systemImage: SettingsTab.models.systemImage)
                }
        }
        .frame(minWidth: 512, minHeight: 512)
    }
}
