//
//  CodeHighlighter.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 06/07/24.
//

import Highlightr
import MarkdownUI
import SwiftUI

@Observable
class CodeHighlighter: CodeSyntaxHighlighter {
    private let highlightr: Highlightr
    private(set) var scheme: ColorScheme = .dark

    init() {
        guard let highlightrInstance = Highlightr() else {
            fatalError("Failed to initialize Highlightr")
        }

        self.highlightr = highlightrInstance
        self.highlightr.setTheme(to: "atom-one-dark")
    }

    func highlightCode(_ code: String, language: String?) -> Text {
        let highlightedCode: NSAttributedString?

        if let language, !language.isEmpty {
            highlightedCode = highlightr.highlight(code, as: language)
        } else {
            highlightedCode = highlightr.highlight(code)
        }

        guard let highlightedCode else { return Text(code) }

        var attributedCode = AttributedString(highlightedCode)
        attributedCode.font = .system(size: 15, design: .monospaced)

        return Text(attributedCode)
    }

    func setColorScheme(to scheme: ColorScheme) {
        let newTheme = scheme == .dark ? "atom-one-dark" : "atom-one-light"
        self.highlightr.setTheme(to: newTheme)
        self.scheme = scheme
    }
}
