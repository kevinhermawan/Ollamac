//
//  SettingsView.swift
//
//
//  Created by Kevin Hermawan on 13/07/24.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack {
            TabView {
                GeneralView()
                    .tabItem {
                        Label("General", systemImage: "gearshape")
                    }
                
                ExperimentalView()
                    .tabItem {
                        Label("Experimental", systemImage: "testtube.2")
                    }
            }
        }
        .padding()
        .frame(width: 512)
    }
}
