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

/// Manages storing and retrieving kids' activity data.
class ActivityManager: ObservableObject {
    @Published var activities: [Activity] = []

    private let storageKey = "activities"

    /// Logs a new activity session.
    func logActivity(_ activity: Activity) {
        activities.append(activity)
        saveToStorage()
    }

    /// Retrieves today's activity.
    func getTodayActivity() -> Activity? {
        let today = Calendar.current.startOfDay(for: Date())
        return activities.first { Calendar.current.startOfDay(for: $0.date) == today }
    }

    /// Fetches weekly summary of activities.
    func getWeeklySummary() -> [Activity] {
        let calendar = Calendar.current
        guard let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) else {
            return [] // Return an empty array if the date calculation fails
        }
        return activities.filter { $0.date >= oneWeekAgo }
    }


    /// Checks the current streak of consecutive days meeting the 60-minute goal.
    func checkStreak() -> Int {
        var streak = 0
        let calendar = Calendar.current  // Ensure calendar is defined
        let sortedActivities = activities.sorted(by: { $0.date > $1.date })
        var previousDate: Date?

        for activity in sortedActivities {
            let activityDate = calendar.startOfDay(for: activity.date)
            if let prev = previousDate, calendar.date(byAdding: .day, value: -1, to: prev) != activityDate {
                break // Streak is broken
            }
            if activity.activeMinutes >= 60 {
                streak += 1
                previousDate = activityDate
            }
        }
        return streak
    }

    /// Provides motivational feedback based on activity progress.
    func triggerMotivation() -> String {
        if let todayActivity = getTodayActivity() {
            if todayActivity.activeMinutes >= 60 {
                return "🎉 Amazing! You've reached your daily goal of 60 minutes!"
            } else {
                let remainingMinutes = 60 - todayActivity.activeMinutes
                return "Keep going! Only \(remainingMinutes) more minutes to reach today's goal! 🚀"
            }
        } else {
            return "Start your activity today and move towards your goal! 💪"
        }
    }

    /// Saves activities to storage.
    private func saveToStorage() {
        if let data = try? JSONEncoder().encode(activities) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
