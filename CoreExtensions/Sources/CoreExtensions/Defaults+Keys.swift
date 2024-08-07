//
//  Defaults+Keys.swift
//
//
//  Created by Kevin Hermawan on 13/07/24.
//

import Defaults
import Foundation
import AppKit.NSFont

public extension Defaults.Keys {
    static let defaultHost = Key<String>("defaultHost", default: "http://localhost:11434")
    static let fontSize = Key<Double>("fontSize", default: NSFont.systemFontSize)
}
