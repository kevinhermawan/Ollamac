//
//  String+IsValidURL.swift
//
//
//  Created by Kevin Hermawan on 13/07/24.
//

import Foundation

public extension String {
    func isValidURL() -> Bool {
        guard let url = URL(string: self), let _ = url.host else { return false }
        
        return true
    }
}
