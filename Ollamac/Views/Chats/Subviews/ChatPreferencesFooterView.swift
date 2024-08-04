//
//  ChatPreferencesFooterView.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 8/4/24.
//

import SwiftUI

struct ChatPreferencesFooterView: View {
    private let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        VStack {
            Text(text)
                .multilineTextAlignment(.leading)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
