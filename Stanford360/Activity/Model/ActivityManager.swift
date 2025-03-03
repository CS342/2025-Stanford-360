//
//  ActivityManager.swift
//  Stanford360
//
//  Created by Elsa Bismuth on 29/01/2025.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT

import Foundation
import Spezi
import StoreKit
import SwiftUI
import SwiftUICore
import UserNotifications

@Observable
class ActivityManager: Module, EnvironmentAccessible {
    // MARK: - Properties
    var activities: [Activity] = []
	var activitiesByDate: [Date: [Activity]] {
		var activitiesByDate: [Date: [Activity]] = [:]
		for activity in activities {
			let normalizedDate = Calendar.current.startOfDay(for: activity.date)
			activitiesByDate[normalizedDate, default: []].append(activity)
		}
		
		return activitiesByDate
	}
    
    // MARK: - Initialization
	init(activities: [Activity] = []) {
		self.activities = activities
    }
    
    // MARK: - Methods
    func getTodayTotalMinutes() -> Int {
        let today = Date()
        return activities
            .filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
            .reduce(0) { $0 + $1.activeMinutes }
    }
	
	func getTotalActivityMinutes(_ activities: [Activity]) -> Int {
		activities.reduce(0) { $0 + $1.activeMinutes }
	}

    // Method to edit an existing activity
    func editActivity(_ updatedActivity: Activity) {
        if let index = activities.firstIndex(where: { $0.id == updatedActivity.id }) {
            activities[index] = updatedActivity
        }
    }

    // Method to delete an activity
    func deleteActivity(_ activity: Activity) {
        activities.removeAll { $0.id == activity.id }
    }
    
//    func getTodayActivity() -> Activity? {
//        let today = Calendar.current.startOfDay(for: Date())
//        return activities.first { Calendar.current.startOfDay(for: $0.date) == today }
//    }
    
    func getWeeklySummary() -> [Activity] {
        let calendar = Calendar.current
        guard let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) else {
            return []
        }
        return activities.filter { $0.date >= oneWeekAgo }
    }
    
    func getMonthlyActivities() -> [Activity] {
        let calendar = Calendar.current
        guard let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: Date()) else {
            return []
        }
        return activities
            .filter { $0.date >= oneMonthAgo }
            .sorted { $0.date < $1.date }
    }
    
//    func checkStreak() -> Int {
//        var streak = 0
//        let calendar = Calendar.current
//        let sortedActivities = activities.sorted(by: { $0.date > $1.date })
//        var previousDate: Date?
//        
//        for activity in sortedActivities {
//            let activityDate = calendar.startOfDay(for: activity.date)
//            if let prev = previousDate, calendar.date(byAdding: .day, value: -1, to: prev) != activityDate {
//                break
//            }
//            if activity.activeMinutes >= 60 {
//                streak += 1
//                previousDate = activityDate
//            }
//        }
//        return streak
//    }
//    
    func triggerMotivation() -> String {
        if getTodayTotalMinutes() >= 60 {
            return "🎉 Amazing! You've reached your daily goal of 60 minutes!"
        } else if getTodayTotalMinutes() > 0 {
            let remainingMinutes = 60 - getTodayTotalMinutes()
            return "Keep going! Only \(remainingMinutes) more minutes to reach today's goal! 🚀"
        } else {
            return "Start your activity today and move towards your goal! 💪"
        }
    }
    
//    private func loadFromStorage() {
//        if let data = UserDefaults.standard.data(forKey: "activities"),
//           let decoded = try? JSONDecoder().decode([Activity].self, from: data) {
//            activities = decoded
//        }
//    }
    
    func saveToStorage() {
        if let data = try? JSONEncoder().encode(activities) {
            UserDefaults.standard.set(data, forKey: "activities")
        }
    }
}
