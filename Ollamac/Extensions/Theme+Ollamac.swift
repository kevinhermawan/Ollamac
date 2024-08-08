//
//  Theme+Ollamac.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 8/3/24.
//

import Foundation
import MarkdownUI
import SwiftUI

extension Theme {
    static let ollamac = Theme()
        .text {
            FontSize(16.0)
        }
        .paragraph { configuration in
            configuration.label
                .relativeLineSpacing(.em(0.25))
        }
        .code {
            FontSize(15.0)
            FontFamilyVariant(.monospaced)
        }
        .codeBlock { configuration in
            CodeBlockView(configuration: configuration)
        }
        .listItem { configuration in
            configuration.label
                .markdownMargin(top: .em(0.15))
        }
}

fileprivate struct CodeBlockView: View {
    let configuration: CodeBlockConfiguration
    
    @State private var isCopied = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(configuration.language?.capitalized ?? "")
                    .foregroundStyle(.white)
                
                Spacer()
                
                Button(action: copyCodeAction) {
                    Text(isCopied ? "Copied" : "Copy Code")
                        .foregroundStyle(.white)
                        .frame(width: 80)
                        .padding(4)
                }
                .buttonStyle(.plain)
                .cornerRadius(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color(hex: "#a5a5a9"), lineWidth: 1)
                )
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(hex: "#373941"))
            
            configuration.label
                .padding(.top, 8)
                .padding(.bottom)
                .padding(.horizontal)
        }
        .background(Color(hex: "#20242b"))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.secondary, lineWidth: 0.2)
        )
    }
    
    private func copyCodeAction() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(configuration.content, forType: .string)
        
        isCopied = true
    }
}
