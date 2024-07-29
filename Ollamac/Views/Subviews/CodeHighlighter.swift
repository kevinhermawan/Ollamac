//
//  CodeHighlighter.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 06/07/24.
//

import Highlightr
import MarkdownUI
import SwiftUI

struct CodeHighlighter: CodeSyntaxHighlighter {
    private let highlightr: Highlightr
    private let font: Font

    init(theme: String, font: Font = .system(.body, design: .monospaced)) {
        guard let highlightrInstance = Highlightr() else {
            fatalError("Failed to initialize Highlightr")
        }
        self.font = font
        self.highlightr = highlightrInstance
        self.highlightr.setTheme(to: theme)
    }
    
    func highlightCode(_ code: String, language: String?) -> Text {
        guard language?.isEmpty == false, let highlightedCode = highlightr.highlight(code, as: language) else {
            return Text(code)
        }
        
        var attributedCode = AttributedString(highlightedCode)
        attributedCode.font = font
        return Text(attributedCode)
    }
}

extension CodeSyntaxHighlighter where Self == CodeHighlighter {
    static func codeHighlighter(theme: String, fontSize: Double) -> Self {
        CodeHighlighter(theme: theme, font: .system(size: fontSize, design: .monospaced))
    }
}
