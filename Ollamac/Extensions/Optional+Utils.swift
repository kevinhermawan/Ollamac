//
//  Optional+Utils.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 11/12/23.
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
