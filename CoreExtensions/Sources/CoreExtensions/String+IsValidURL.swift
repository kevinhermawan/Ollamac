//
//  String+IsValidURL.swift
//
//
//  Created by Kevin Hermawan on 13/07/24.
//

import Foundation

public extension String {
    func isValidURL() -> Bool {
        let urlRegEx = #"^(http|https):\/\/((([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,})|(localhost))(:[0-9]{1,5})?(\/[^\s]*)?$"#
        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
        
        return urlTest.evaluate(with: self)
    }
}
