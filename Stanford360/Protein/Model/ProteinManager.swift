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
        calculateStreak()
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
	
    func calculateStreak() -> Int {
        let calendar = Calendar.current
        var streakCount = 0
        var currentDate = calendar.startOfDay(for: Date())

        let todayIntake = mealsByDate[currentDate]?.reduce(0) { $0 + $1.proteinGrams } ?? 0.0
        let isTodayQualified = todayIntake >= 60

        guard let previousDate = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
            return isTodayQualified ? 1 : 0
        }
        currentDate = previousDate

        while true {
            let dailyIntake = mealsByDate[currentDate]?.reduce(0) { $0 + $1.proteinGrams } ?? 0.0

            if dailyIntake >= 60 {
                streakCount += 1
                guard let previousDate = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                    break
                }
                currentDate = previousDate
            } else {
                break
            }
        }

        return isTodayQualified ? streakCount + 1 : streakCount
    }
	
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
