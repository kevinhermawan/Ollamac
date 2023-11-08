//
//  Encodable+Parameters.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 04/11/23.
//

import Alamofire
import Foundation

extension Encodable {
    func asParameters() -> Parameters? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        guard let dictionary = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? Parameters else {
            return nil
        }
        
        return dictionary
    }
}
