//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation

// Protein Intake Model
struct ProteinIntakeModel {
    var userID: String // Unique identifier for the user
    var date: Date // The date of the intake record
    var meals: [Meal] // List of meals consumed by the user

    // Computed property to calculate the total protein intake for the day
    var totalProteinGrams: Double {
        meals.reduce(0) { $0 + $1.proteinGrams }
    }

    // add a new meal to the list
    mutating func addMeal(name: String, proteinGrams: Double, imageURL: String? = nil, timestamp: Date = Date()) {
        let newMeal = Meal(name: name, proteinGrams: proteinGrams, imageURL: imageURL, timestamp: timestamp)
        meals.append(newMeal)
    }

    // delete a meal from the list by its name
    mutating func deleteMeal(byName name: String) {
        meals.removeAll { $0.name == name }
    }

    // update an existing meal's details
    mutating func updateMeal(oldName: String, newName: String, newProteinGrams: Double, newImageURL: String? = nil, newTimestamp: Date = Date()) {
        if let index = meals.firstIndex(where: { $0.name == oldName }) {
            meals[index] = Meal(name: newName, proteinGrams: newProteinGrams, imageURL: newImageURL, timestamp: newTimestamp)
        }
    }

    // filter meals by a specific date
    func filterMeals(byDate targetDate: Date) -> [Meal] {
        meals.filter { Calendar.current.isDate($0.timestamp, inSameDayAs: targetDate) }
    }
}
