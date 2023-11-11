//
//  FormErrorView.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 11/11/23.
//

import SwiftUI

struct FormErrorView<Content: View>: View {
    let message: String
    var content: Content?

    init(message: String, @ViewBuilder content: () -> Content? = { nil }) {
        self.message = message
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(message)
                .foregroundColor(.red)
            
            content
        }
        .frame(minHeight: 32)
        .padding(.vertical, 8)
    }
}

#Preview {
    FormErrorView(message: AppMessages.generalErrorMessage) {}
}
