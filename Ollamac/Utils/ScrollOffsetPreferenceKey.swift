//
//  ScrollOffsetPreferenceKey.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 8/4/24.
//

import Foundation
import SwiftUI

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
