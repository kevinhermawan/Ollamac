//
//  Defaults+Keys.swift
//
//
//  Created by Kevin Hermawan on 13/07/24.
//

import Defaults
import Foundation

extension Defaults.Keys {
    static let defaultHost = Key<String>("defaultHost", default: "http://localhost:11434")
    static let lastUsedModel = Key<String?>("lastUsedModel", default: nil)
}
