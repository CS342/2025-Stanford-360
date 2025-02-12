//
//  ActivityManager.swift
//  Stanford360
//
//  Created by Elsa Bismuth on 29/01/2025.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
import BackgroundTasks
import FirebaseCore
import FirebaseFirestore
import Foundation
import UserNotifications

/// Manages storing and retrieving kids' activity data.
@Observable
class ActivityManager {
    var activities: [Activity] = []
   
    private let storageKey = "activities"
    
//    private var db = Firestore.firestore()

    /// Logs a new activity session.
    func logActivityToView(_ activity: Activity) {
        activities.append(activity)
        sendActivityReminder()
        saveToStorage() // Local storage backup, if needed.
    }
    
    /// Retrieves today's activity.
    func getTodayActivity() -> Activity? {
        let today = Calendar.current.startOfDay(for: Date())
        return activities.first { Calendar.current.startOfDay(for: $0.date) == today }
    }

//    /// Fetches weekly summary of activities.
//    func getWeeklySummary() -> [Activity] {
//        let calendar = Calendar.current
//        guard let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) else {
//            return [] // Return an empty array if the date calculation fails
//        }
//        return activities.filter { $0.date >= oneWeekAgo }
//    }

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
        // Get today's date and filter all activities logged today.
        let today = Date()
        let totalActiveMinutes = activities
            .filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
            .reduce(0) { $0 + $1.activeMinutes }

        if totalActiveMinutes >= 60 {
            return "🎉 Amazing! You've reached your daily goal of 60 minutes!"
        } else if totalActiveMinutes > 0 {
            let remainingMinutes = 60 - totalActiveMinutes
            return "Keep going! Only \(remainingMinutes) more minutes to reach today's goal! 🚀"
        } else {
            return "Start your activity today and move towards your goal! 💪"
        }
    }
    
//    /// Schedules a background task to check activity progress
//    func scheduleBackgroundActivityCheck() {
//        let request = BGAppRefreshTaskRequest(identifier: "com.Stanford360.activityReminder")
//        request.earliestBeginDate = Date(timeIntervalSinceNow: 5 * 60 * 60) // Run in 5 hours
//        
//        do {
//            try BGTaskScheduler.shared.submit(request)
//        } catch {
//            print("Failed to schedule background task: \(error)")
//        }
//    }
//
//    /// Handles the background task execution
//    func handleBackgroundActivityCheck(task: BGAppRefreshTask) {
//        sendActivityReminder()
//        task.setTaskCompleted(success: true)
//        scheduleBackgroundActivityCheck() // Reschedule for continuous monitoring
//    }

    /// Sends a notification reminder based on activity progress.
    func sendActivityReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["activityReminder"])
        
        let today = Date()
        let totalActiveMinutes = activities
            .filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
            .reduce(0) { $0 + $1.activeMinutes }
        
        let content = UNMutableNotificationContent()
        content.title = "🏃 Keep Moving!"
        
        if totalActiveMinutes >= 60 {
            content.body = "🎉 Amazing! You've reached your daily goal of 60 minutes! Keep up the great work!"
        } else {
            let remainingMinutes = 60 - totalActiveMinutes
            content.body = "You're only \(remainingMinutes) minutes away from your daily goal! Keep going! 🚀"
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5 * 60 * 60, repeats: false)
            let request = UNNotificationRequest(identifier: "activityReminder", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request)
        }
    }

    /// Saves activities to storage.
    private func saveToStorage() {
        if let data = try? JSONEncoder().encode(activities) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
