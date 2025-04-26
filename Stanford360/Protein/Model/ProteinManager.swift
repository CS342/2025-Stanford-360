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
	
    
    var streak: Int {
        let calendar = Calendar.current
        var streakCount = 0
        var currentDate = calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date()

        let todayIntake = getTotalProteinGrams(mealsByDate[calendar.startOfDay(for: Date())] ?? [])
        let isTodayQualified = todayIntake >= 60

        while true {
            let dailyIntake = getTotalProteinGrams(mealsByDate[calendar.startOfDay(for: currentDate)] ?? [])

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
}
