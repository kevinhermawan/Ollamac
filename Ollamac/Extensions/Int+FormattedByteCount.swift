//
//  Int+FormattedByteCount.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 14/11/23.
//

import Foundation

extension Int {
    var formattedByteCount: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        
        return formatter.string(fromByteCount: Int64(self))
    }
}
