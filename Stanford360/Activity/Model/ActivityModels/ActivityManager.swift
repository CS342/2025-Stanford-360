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
import UserNotifications

@MainActor
@Observable
class ActivityManager {
    var activities: [Activity] = []
    private let storageKey = "activities"
    private let healthKitManager: HealthKitManager
    
    var todayTotalMinutes: Int {
        let today = Date()
        return activities
            .filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
            .reduce(0) { $0 + $1.activeMinutes }
    }
    
    init(healthKitManager: HealthKitManager = HealthKitManager()) {
        self.healthKitManager = healthKitManager
        loadFromStorage()
        setupHealthKit()
    }
    
    private func setupHealthKit() {
        Task {
            do {
                try await healthKitManager.requestAuthorization()
                await syncHealthKitData()
            } catch {
                print("Failed to setup HealthKit: \(error)")
            }
        }
    }
    
    func syncHealthKitData() async {
        do {
            let healthKitActivity = try await healthKitManager.readDailyActivity(for: Date())
            
            // Check if a similar HealthKit activity already exists
            let newActivity = healthKitActivity.toActivity()
            let existingHealthKitActivities = activities.filter {
                $0.activityType == "HealthKit" &&
                Calendar.current.isDateInToday($0.date) &&
                $0.steps == newActivity.steps &&
                $0.activeMinutes == newActivity.activeMinutes &&
                $0.caloriesBurned == newActivity.caloriesBurned
            }
            
            // Add activity if no identical one exists
            if existingHealthKitActivities.isEmpty {
                logActivityToView(newActivity)
            }
        } catch {
            print("Failed to sync HealthKit data: \(error)")
        }
    }

    func logActivityToView(_ activity: Activity) {
        activities.append(activity)
        saveToStorage()
        
        // Save non-HealthKit activities to HealthKit
        if activity.activityType != "HealthKit" {
            Task {
                try? await healthKitManager.saveActivity(activity)
            }
        }
    }
    
    func getTodayActivity() -> Activity? {
        let today = Calendar.current.startOfDay(for: Date())
        return activities.first { Calendar.current.startOfDay(for: $0.date) == today }
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
    
    func checkStreak() -> Int {
        var streak = 0
        let calendar = Calendar.current
        let sortedActivities = activities.sorted(by: { $0.date > $1.date })
        var previousDate: Date?
        
        for activity in sortedActivities {
            let activityDate = calendar.startOfDay(for: activity.date)
            if let prev = previousDate, calendar.date(byAdding: .day, value: -1, to: prev) != activityDate {
                break
            }
            if activity.activeMinutes >= 60 {
                streak += 1
                previousDate = activityDate
            }
        }
        return streak
    }
    
    func triggerMotivation() -> String {
        if todayTotalMinutes >= 60 {
            return "🎉 Amazing! You've reached your daily goal of 60 minutes!"
        } else if todayTotalMinutes > 0 {
            let remainingMinutes = 60 - todayTotalMinutes
            return "Keep going! Only \(remainingMinutes) more minutes to reach today's goal! 🚀"
        } else {
            return "Start your activity today and move towards your goal! 💪"
        }
    }
    
    func sendActivityReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["activityReminder"])
        
        let content = UNMutableNotificationContent()
        content.title = "🏃 Keep Moving!"
        
        if todayTotalMinutes >= 60 {
            content.body = "🎉 Amazing! You've reached your daily goal of 60 minutes! Keep up the great work!"
        } else {
            let remainingMinutes = 60 - todayTotalMinutes
            content.body = "You're only \(remainingMinutes) minutes away from your daily goal! Keep going! 🚀"
            let request = UNNotificationRequest(identifier: "activityReminder", content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    private func loadFromStorage() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([Activity].self, from: data) {
            activities = decoded
        }
    }
    
    private func saveToStorage() {
        if let data = try? JSONEncoder().encode(activities) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
