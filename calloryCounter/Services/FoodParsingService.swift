//
//  FoodParsingService.swift
//  calloryCounter
//
//  Created by ellkaden on 11.12.2025.
//


import Foundation

struct FoodParsingService {
    func parse(_ input: String) -> (name: String, calories: Int)? {
        let cleaned = input.trimmingCharacters(in: .whitespaces)
        
        let patterns = [
            "^([а-яА-ЯёЁa-zA-Z\\s]+)[,\\s]+([0-9]+)$",
            "^([а-яА-ЯёЁa-zA-Z\\s]+)\\(([0-9]+)\\)$"
        ]
        
        for pattern in patterns {
            let regex = try? NSRegularExpression(pattern: pattern)
            let range = NSRange(cleaned.startIndex..., in: cleaned)
            
            if let match = regex?.firstMatch(in: cleaned, range: range) {
                if match.numberOfRanges == 3,
                   let nameRange = Range(match.range(at: 1), in: cleaned),
                   let caloriesRange = Range(match.range(at: 2), in: cleaned),
                   let calories = Int(String(cleaned[caloriesRange])) {
                    let name = String(cleaned[nameRange]).trimmingCharacters(in: .whitespaces)
                    return (name, calories)
                }
            }
        }
        return nil
    }
}
