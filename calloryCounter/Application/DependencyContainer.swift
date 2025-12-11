//
//  DependencyContainer.swift
//  calloryCounter
//
//  Created by ellkaden on 11.12.2025.
//

import SwiftData

struct DependencyContainer {
    static func setupContainer() -> ModelContext {
        do {
            let config = ModelConfiguration(
                isStoredInMemoryOnly: false,
                allowsSave: true
            )
            
            let container = try ModelContainer(
                for: FoodItem.self,
                configurations: config
            )
            
            return ModelContext(container)
        } catch {
            fatalError("Не удалось инициализировать ModelContainer: \(error)")
        }
    }
}
