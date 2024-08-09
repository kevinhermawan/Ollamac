//
//  Theme+Ollamac.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 8/3/24.
//

import Foundation
import MarkdownUI
import SwiftUI

class ThemeCache {
    static let shared = ThemeCache()
    private var cachedTheme: Theme?
    private var cachedCodeBlocks: [CodeBlockConfiguration: CodeBlockView] = [:]
    
    func getTheme() -> Theme {
        if let existingTheme = cachedTheme {
            return existingTheme
        } else {
            let newTheme = Theme()
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
                .codeBlock { [weak self] configuration in
                    self?.getCodeBlockView(for: configuration) ?? CodeBlockView(configuration: configuration)
                }
            
            cachedTheme = newTheme
            
            return newTheme
        }
    }
    
    private func getCodeBlockView(for configuration: CodeBlockConfiguration) -> CodeBlockView {
        if let cachedView = cachedCodeBlocks[configuration] {
            return cachedView
        } else {
            let newView = CodeBlockView(configuration: configuration)
            cachedCodeBlocks[configuration] = newView
            
            return newView
        }
    }
}

extension Theme {
    static var ollamac: Theme {
        ThemeCache.shared.getTheme()
    }
}
