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
    let milestoneManager = MilestoneManager()
	var activitiesByDate: [Date: [Activity]] {
		var activitiesByDate: [Date: [Activity]] = [:]
		for activity in activities {
			let normalizedDate = Calendar.current.startOfDay(for: activity.date)
			activitiesByDate[normalizedDate, default: []].append(activity)
		}
		
		return activitiesByDate
	}

    // Streak Calculation
    var streak: Int {
        let calendar = Calendar.current
        var streakCount = 0
        var currentDate = Date()

        while let activitiesForDate = activitiesByDate[calendar.startOfDay(for: currentDate)] {
            let totalMinutes = getTotalActivityMinutes(activitiesForDate)
            if totalMinutes >= 60 {
                streakCount += 1
            } else {
                break // Stop counting if the total minutes are not over 60
            }
            // Move to the previous day
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }

        return streakCount
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
    
    func getLatestMilestone() -> Double {
        let totalIntake = Double(getTodayTotalMinutes())
        return milestoneManager.getLatestMilestone(total: totalIntake)
    }

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
    
    func saveToStorage() {
        do {
            let data = try JSONEncoder().encode(activities)
            UserDefaults.standard.set(data, forKey: "activities")
            print("[ActivityManager] [saveToStorage] Successfully saved activities to UserDefaults")
        } catch {
            print("[ActivityManager] [saveToStorage] Error ❌ : \(error)")
        }
    }
}
