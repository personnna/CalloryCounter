//
//  FoodItem.swift
//  calloryCounter
//
//  Created by ellkaden on 11.12.2025.
//

import SwiftData
import Foundation

@Model
final class FoodItem {
    var id: UUID = UUID()
    var name: String
    var calories: Int
    var dateAdded: Date = Date()
    var photoData: Data?
    
    init(name: String, calories: Int, photoData: Data? = nil) {
        self.name = name
        self.calories = calories
        self.photoData = photoData
    }
}
