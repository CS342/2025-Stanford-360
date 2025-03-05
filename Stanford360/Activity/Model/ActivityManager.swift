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
    
    // Streak Calculation
    var streak: Int {
        let calendar = Calendar.current
        let now = Date()
        let todayStart = calendar.startOfDay(for: now)
        
        // Safely calculate yesterday
        guard let previousDate = calendar.date(byAdding: .day, value: -1, to: todayStart) else {
            return 0 // error
        }
        var dateToCheck = previousDate
        
        // Calculate streak for previous days
        var streakCount = 0
        while let activities = activitiesByDate[dateToCheck] {
            let minutes = getTotalActivityMinutes(activities)
            if minutes >= 60 {
                streakCount += 1
            } else {
                break
            }
            guard let newDate = calendar.date(byAdding: .day, value: -1, to: dateToCheck) else {
                return 0 // error
            }
            dateToCheck = newDate
        }
        
        // Handle today's activity separately
        if let todaysActivities = activitiesByDate[todayStart],
           getTotalActivityMinutes(todaysActivities) >= 60 {
            streakCount += 1
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
