//
//  Optional+Utils.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 13/07/24.
//

import Foundation

extension Optional {
    var isNil: Bool {
        self == nil
    }
    
    var isNotNil: Bool {
        self != nil
    }
}
