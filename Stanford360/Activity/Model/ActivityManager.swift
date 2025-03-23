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

    var streak: Int {
        let calendar = Calendar.current
        var streakCount = 0
        var currentDate = calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date()

        let todayIntake = getTotalActivityMinutes(activitiesByDate[calendar.startOfDay(for: Date())] ?? [])
        let isTodayQualified = todayIntake >= 60

        while true {
            let dailyIntake = getTotalActivityMinutes(activitiesByDate[calendar.startOfDay(for: currentDate)] ?? [])

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
    
    func getStepsFromMinutes(_ minutes: Int) -> Int {
        minutes * 100
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
