//
//  MarkdownStyling.swift
//  Ollamac
//
//  Created by Philipp on 29.07.2024.
//

import MarkdownUI
import SwiftUI

struct MarkdownStyling: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(CodeHighlighter.self) private var codeHighlighter

    func body(content: Content) -> some View {
        content
            .markdownCodeSyntaxHighlighter(codeHighlighter)
            .markdownTextStyle(\.text) {
                FontSize(NSFont.systemFont(ofSize: 16).pointSize)
            }
            .markdownTextStyle(\.code) {
                FontSize(NSFont.systemFont(ofSize: 16).pointSize)
                FontFamily(.system(.monospaced))
            }
            .markdownBlockStyle(\.paragraph) { configuration in
                configuration.label
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .markdownBlockStyle(\.codeBlock) { configuration in
                configuration.label
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(nsColor: .tertiarySystemFill))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.separator, lineWidth: 1)
                    )
            }
            .onChange(of: colorScheme, initial: true) {
                codeHighlighter.setTheme(to: theme)
            }
    }

    private var theme: String {
        colorScheme == .dark ? "atom-one-dark" : "atom-one-light"
    }
}

extension View {
    func markdownStyling() -> some View {
        modifier(MarkdownStyling())
    }
}
