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
        calculateStreak()
    }
    
    // MARK: - Initialization
	init(activities: [Activity] = []) {
		self.activities = activities
    }
	
	func reverseSortActivitiesByDate(_ activities: [Activity]) -> [Activity] {
		activities.sorted { $0.date > $1.date }
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
    
    func calculateStreak() -> Int {
        let calendar = Calendar.current
        var streakCount = 0
        var currentDate = calendar.startOfDay(for: Date())

        let todayIntake = activitiesByDate[currentDate]?.reduce(0) { $0 + $1.activeMinutes } ?? 0
        let isTodayQualified = todayIntake >= 60

        guard let previousDate = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
            return isTodayQualified ? 1 : 0
        }
        currentDate = previousDate

        while true {
            let dailyIntake = activitiesByDate[currentDate]?.reduce(0) { $0 + $1.activeMinutes } ?? 0

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
