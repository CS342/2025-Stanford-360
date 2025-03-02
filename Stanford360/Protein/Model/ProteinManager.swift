//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Combine
import Foundation
import Spezi

// Protein Intake Model, can also be reviewed as a meal controller
@Observable
class ProteinManager: Module, EnvironmentAccessible {
	var meals: [Meal] // List of meals consumed by the user
	
	init(meals: [Meal] = []) {
		self.meals = meals
	}
	
	func getTodayTotalGrams() -> Double {
		let today = Date()
		return meals
			.filter { Calendar.current.isDate($0.timestamp, inSameDayAs: today) }
			.reduce(0) { $0 + $1.proteinGrams }
	}
    
//    func getThisWeekTotalGrams() -> Double {
//        let today = Date()
//        let calendar = Calendar.current
//        
//        return meals
//            .filter {
//                calendar.isDate($0.timestamp, equalTo: today, toGranularity: .weekOfYear)
//            }
//            .reduce(0) { $0 + $1.proteinGrams }
//    }
//
//    
//    func getThisMonthTotalGrams() -> Double {
//        let today = Date()
//        let calendar = Calendar.current
//
//        return meals
//            .filter {
//                calendar.isDate($0.timestamp, equalTo: today, toGranularity: .month)
//            }
//            .reduce(0) { $0 + $1.proteinGrams }
//    }

	
	// Add a new meal to the list
	func addMeal(name: String, proteinGrams: Double, /*imageURL: String? = nil, */timestamp: Date = Date()) {
		let newMeal = Meal(name: name, proteinGrams: proteinGrams, /*imageURL: imageURL,*/ timestamp: timestamp)
		meals.append(newMeal)
	}
	
//    // Delete a meal from the list by its id
//    func deleteMeal(byID id: String) {
//        meals.removeAll { $0.id == id }
//    }
//	
	// Update an existing meal's details
	//	func updateMeal(
	//		oldName: String,
	//		newName: String,
	//		newProteinGrams: Double,
	//		// newImageURL: String? = nil,
	//		newTimestamp: Date = Date()
	//	) {
	//		if let index = meals.firstIndex(where: { $0.name == oldName }) {
	//			meals[index] = Meal(
	//				name: newName,
	//				proteinGrams: newProteinGrams,
	//				// imageURL: newImageURL,
	//				timestamp: newTimestamp
	//			)
	//		}
	//	}
}
