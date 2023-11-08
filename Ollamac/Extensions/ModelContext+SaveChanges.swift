//
//  ModelContext+SaveChanges.swift
//  Ollamac
//
//  Created by Kevin Hermawan on 05/11/23.
//

import SwiftData

extension ModelContext {
    func saveChanges() throws {
        if self.hasChanges {
            try self.save()
        }
    }
}
