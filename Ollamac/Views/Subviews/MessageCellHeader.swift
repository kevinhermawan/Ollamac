//
//  MessageCellHeader.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 06/07/24.
//

import SwiftUI

struct MessageCellHeader: View {
    private let content: String
    
    init(_ content: String) {
        self.content = content
    }
    
    var body: some View {
        Text(content)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.purple)
    }
}

#Preview {
    List {
        MessageCellHeader("You")
        MessageCellHeader("Assistant")
    }
}
