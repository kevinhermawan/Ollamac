//
//  Defaults+Keys.swift
//
//
//  Created by Kevin Hermawan on 13/07/24.
//

import Defaults
import Foundation

public extension Defaults.Keys {
    static let defaultHost = Key<String>("defaultHost", default: "http://localhost:11434")
    static let defaultFontSize = Key<Double>("defaultFontSize", default: 16.0)
}
