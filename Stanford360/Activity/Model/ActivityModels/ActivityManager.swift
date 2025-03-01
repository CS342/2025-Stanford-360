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

// enum TimeFrame {
//    case today
//    case week
//    case month
// }

@MainActor
@Observable
class ActivityManager: Module, EnvironmentAccessible {
    // MARK: - Properties
    var activities: [Activity] = []
    
    // MARK: - Initialization
    init() {
    }
    
    // MARK: - Methods
    func getTodayTotalMinutes() -> Int {
        let today = Date()
        return activities
            .filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
            .reduce(0) { $0 + $1.activeMinutes }
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
    
    func sendActivityReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["activityReminder"])
        
        let content = UNMutableNotificationContent()
        content.title = "🏃 Keep Moving!"
        
        if getTodayTotalMinutes() >= 60 {
            content.body = "🎉 Amazing! You've reached your daily goal of 60 minutes! Keep up the great work!"
        } else {
            let remainingMinutes = 60 - getTodayTotalMinutes()
            content.body = "You're only \(remainingMinutes) minutes away from your daily goal! Keep going! 🚀"
            let request = UNNotificationRequest(identifier: "activityReminder", content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request)
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
    
//    // Helper methods to get activities for different time frames
//    func getActivitiesForTimeFrame(_ timeFrame: TimeFrame) -> [Activity] {
//        let calendar = Calendar.current
//        let now = Date()
//        
//        switch timeFrame {
//        case .today:
//            let todayActivities = activities.filter { calendar.isDateInToday($0.date) }
//            return todayActivities
//            
//        case .week:
//            guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) else {
//                return []
//            }
//            let weekActivities = activities.filter { $0.date >= weekAgo && $0.date <= now }
//            return weekActivities
//            
//        case .month:
//            guard let monthAgo = calendar.date(byAdding: .month, value: -1, to: now) else {
//                return []
//            }
//            let monthActivities = activities.filter { $0.date >= monthAgo && $0.date <= now }
//            return monthActivities
//        }
//    }
}
