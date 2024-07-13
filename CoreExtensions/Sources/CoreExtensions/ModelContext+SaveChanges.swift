//
//  ModelContext+SaveChanges.swift
//  CoreExtensions
//
//  Created by Kevin Hermawan on 13/07/24.
//

import SwiftData

public extension ModelContext {
    func saveChanges() throws {
        if self.hasChanges {
            try self.save()
        }
    }
}
