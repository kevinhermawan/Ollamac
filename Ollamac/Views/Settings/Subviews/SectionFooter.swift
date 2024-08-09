//
//  SectionFooter.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 8/9/24.
//

import SwiftUI

struct SectionFooter: View {
    private let text: LocalizedStringKey
    
    init(_ text: LocalizedStringKey) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .font(.callout)
            .foregroundStyle(.secondary)
    }
}
