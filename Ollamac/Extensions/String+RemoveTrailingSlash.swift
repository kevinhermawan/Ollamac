//
//  String+RemoveTrailingSlash.swift
//
//
//  Created by Kevin Hermawan on 13/07/24.
//

import Foundation

extension String {
    func removeTrailingSlash() -> String {
        return self.hasSuffix("/") ? String(self.dropLast()) : self
    }
}
