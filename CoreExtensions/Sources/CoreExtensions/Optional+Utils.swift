//
//  Optional+Utils.swift
//  CoreExtensions
//
//  Created by Kevin Hermawan on 13/07/24.
//

import Foundation

public extension Optional {
    var isNil: Bool {
        self == nil
    }
    
    var isNotNil: Bool {
        self != nil
    }
}
