//
//  CalorieTrackerViewModel.swift
//  calloryCounter
//
//  Created by ellkaden on 11.12.2025.
//

import Foundation
import SwiftData

protocol CalorieTrackerViewModelDelegate: AnyObject {
    func viewModelDidUpdateItems()
    func viewModelDidShowAlert(type: CalorieTrackerViewModel.AlertType)
}

final class CalorieTrackerViewModel {
    weak var delegate: CalorieTrackerViewModelDelegate?
    
    private let modelContext: ModelContext
    private let parsingService = FoodParsingService()
    
    var items: [FoodItem] = []
    
    var totalCalories: Int {
        items.reduce(0) { $0 + $1.calories }
    }
    
    enum AlertType {
        case duplicateItem(String)
        case invalidFormat
        case success(String, Int)
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchTodayItems()
    }
    
    func addItem(input: String, photoData: Data?) {
        let trimmed = input.trimmingCharacters(in: .whitespaces)
        
        guard !trimmed.isEmpty else {
            delegate?.viewModelDidShowAlert(type: .invalidFormat)
            return
        }
        
        guard let (name, calories) = parsingService.parse(trimmed) else {
            delegate?.viewModelDidShowAlert(type: .invalidFormat)
            return
        }
        
        if items.contains(where: { $0.name.lowercased() == name.lowercased() }) {
            delegate?.viewModelDidShowAlert(type: .duplicateItem(name))
            return
        }
        
        let newItem = FoodItem(name: name, calories: calories, photoData: photoData)
        modelContext.insert(newItem)
        
        do {
            try modelContext.save()
            delegate?.viewModelDidShowAlert(type: .success(name, calories))
            fetchTodayItems()
        } catch {
            print("Ошибка сохранения: \(error)")
        }
    }
    
    func deleteItem(_ item: FoodItem) {
        modelContext.delete(item)
        do {
            try modelContext.save()
            fetchTodayItems()
        } catch {
            print("Ошибка удаления: \(error)")
        }
    }
    
    func updateItem(_ item: FoodItem, newCalories: Int) {
        item.calories = newCalories
        do {
            try modelContext.save()
            fetchTodayItems()
        } catch {
            print("Ошибка обновления: \(error)")
        }
    }
    
    func fetchTodayItems() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        
        let descriptor = FetchDescriptor<FoodItem>(
            predicate: #Predicate<FoodItem> { item in
                item.dateAdded >= today && item.dateAdded < tomorrow
            },
            sortBy: [SortDescriptor(\FoodItem.dateAdded, order: .reverse)]
        )
        
        do {
            items = try modelContext.fetch(descriptor)
            delegate?.viewModelDidUpdateItems()
        } catch {
            print("Ошибка загрузки: \(error)")
        }
    }
}
