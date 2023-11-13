//
//  Date+RelativeDateString.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 14/11/23.
//

import Foundation

extension Date {
    var relativeDateString: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        
        let now = Date()
        let calendar = Calendar.current
        
        if let difference = calendar.dateComponents([.day, .hour, .minute, .second], from: self, to: now).day, difference >= 1 {
            return "\(difference) days ago"
        } else {
            return formatter.string(from: self, to: now) ?? ""
        }
    }
}
