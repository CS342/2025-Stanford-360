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

@Observable
class ProteinManager: Module, EnvironmentAccessible {
	var meals: [Meal]
    let milestoneManager = MilestoneManager()
	var mealsByDate: [Date: [Meal]] {
		var mealsByDate: [Date: [Meal]] = [:]
		for meal in meals {
			let normalizedDate = Calendar.current.startOfDay(for: meal.timestamp)
			mealsByDate[normalizedDate, default: []].append(meal)
		}
		
		return mealsByDate
	}
	
    
    // Streak Calculation
    var streak: Int {
        let calendar = Calendar.current
        var streakCount = 0
        var currentDate = Date()

        while let mealsByDate = mealsByDate[calendar.startOfDay(for: currentDate)] {
            let totalGrams = getTotalProteinGrams(mealsByDate)
            if totalGrams >= 60 {
                streakCount += 1
            } else {
                break // Stop counting if the total minutes are not over 60
            }
            // Move to the previous day
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }

        return streakCount
    }
    
	init(meals: [Meal] = []) {
		self.meals = meals
	}
	
	func reverseSortMealsByDate(_ meals: [Meal]) -> [Meal] {
		meals.sorted { $0.timestamp > $1.timestamp }
	}
	
	func getTodayTotalGrams() -> Double {
		let today = Date()
		return meals
			.filter { Calendar.current.isDate($0.timestamp, inSameDayAs: today) }
			.reduce(0) { $0 + $1.proteinGrams }
	}
	
	func getTotalProteinGrams(_ meals: [Meal]) -> Double {
		meals.reduce(0) { $0 + $1.proteinGrams }
	}
    
    func getLatestMilestone() -> Double {
        let totalIntake = getTodayTotalGrams()
        return milestoneManager.getLatestMilestone(total: totalIntake)
    }
	
    /*
	func triggerMotivation() -> String {
		if getTodayTotalGrams() >= 60 {
			return "🎉 Amazing! You've reached your daily goal of 60 grams!"
		} else if getTodayTotalGrams() > 0 {
			let remainingGrams = 60 - getTodayTotalGrams()
			return "Keep going! Only \(String(format: "%.f", remainingGrams)) more grams to reach today's goal! 🚀"
		} else {
			return "Eat your protein today and move towards your goal! 💪"
		}
	}
     */
	
	// Add a new meal to the list
//	func addMeal(name: String, proteinGrams: Double, imageURL: String? = nil, timestamp: Date = Date()) {
//		let newMeal = Meal(name: name, proteinGrams: proteinGrams, imageURL: imageURL, timestamp: timestamp)
//		meals.append(newMeal)
//	}
	
	// Delete a meal from the list by its name
	//	func deleteMeal(byName name: String) {
	//		meals.removeAll { $0.name == name }
	//	}
	
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
	
	//    // Filter meals by a specific date
	//    func filterMeals(byDate targetDate: Date) -> [Meal] {
	//        meals.filter { Calendar.current.isDate($0.timestamp, inSameDayAs: targetDate) }
	//    }
	
	//    // Compute weekly total protein intake
	//    func getWeeklyProteinIntake() -> Double {
	//        let calendar = Calendar.current
	//        guard let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: date) else {
	//            return 0.0
	//        }
	//        return meals.filter { $0.timestamp >= oneWeekAgo }
	//            .reduce(0) { $0 + $1.proteinGrams }
	//    }
	
	//    // Compute monthly total protein intake
	//    func getMonthlyProteinIntake() -> Double {
	//        let calendar = Calendar.current
	//        guard let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: date) else {
	//            return 0.0
	//        }
	//        return meals.filter { $0.timestamp >= oneMonthAgo }
	//            .reduce(0) { $0 + $1.proteinGrams }
	//    }
}
