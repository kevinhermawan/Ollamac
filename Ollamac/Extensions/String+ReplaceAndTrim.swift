//
//  String+ReplaceAndTrim.swift
//  Ollamac
//
//  Created by Harry on 2/2/25.
//

extension String {
	func replaceAndTrim(string: String) -> Self {
		self.replacingOccurrences(of: string, with: "").trimmingCharacters(in: .whitespaces)
	}
}
