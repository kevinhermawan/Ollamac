//
//  Box.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 8/10/24.
//

import SwiftUI

struct Box<Content: View>: View {
    private let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 6) {
                content()
            }
            .frame(maxWidth: .infinity)
            .padding(8)
        }
    }
}
