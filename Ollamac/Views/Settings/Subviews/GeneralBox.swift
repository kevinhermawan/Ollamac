//
//  GeneralBox.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 8/7/24.
//

import SwiftUI

struct GeneralBox: View {
    private let label: String
    private let value: String
    private let action: () -> Void
    
    init(label: String, value: String, action: @escaping () -> Void) {
        self.label = label
        self.value = value
        self.action = action
    }
    
    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 6) {
                Text(label)
                    .font(.headline.weight(.semibold))
                
                HStack {
                    Text(value)
                        .help(value)
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button("Change", action: action)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(8)
        }
    }
}
