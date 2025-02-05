//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import BackgroundTasks
import Foundation
import SpeziScheduler
import SpeziSchedulerUI
import UserNotifications

// MARK: - Hydration Tracker
class HydrationTracker: ObservableObject {
    @Published var totalIntake: Double = 0.0
    @Published var streak: Int = 0

    private let defaults = UserDefaults.standard
    
    init() {
        loadHydrationData()
    }

    /// **Load Saved Hydration Data**
    func loadHydrationData() {
        totalIntake = defaults.double(forKey: "totalIntakeToday")
        streak = defaults.integer(forKey: "hydrationStreak")
        print("Current Streak:", streak)
    }

    /// **Log Water Intake**
    func logWaterIntake(intakeAmount: Double, completion: @escaping (Bool) -> Void) {
        guard intakeAmount > 0 else {
            completion(false)
            return
        }

        let previousIntake = defaults.double(forKey: "totalIntakeToday")
        let updatedIntake = previousIntake + intakeAmount

        defaults.set(updatedIntake, forKey: "totalIntakeToday")

        totalIntake = updatedIntake

        checkHydrationMilestones(totalIntake: updatedIntake)
        updateHydrationStreak()

        completion(true)
    }

    /// **Check Hydration Milestones**
    func checkHydrationMilestones(totalIntake: Double) {
        let milestoneKey = "lastTriggeredMilestone"
        let lastTriggered = defaults.double(forKey: milestoneKey)

        for milestone in stride(from: 20, through: totalIntake, by: 20) where milestone > lastTriggered {
            let message = milestone == 60
                ? "🎉🎉 Amazing! You've reached 60 oz today! Keep up the great work! 🎉🎉"
                : "🎉 Great job! You've reached \(Int(milestone)) oz of water today!"
            
            sendMotivationalMessage(message)
            defaults.set(milestone, forKey: milestoneKey)
        }
    }

    /// ✅ **Send Motivational Notifications**
    func sendMotivationalMessage(_ message: String) {
        let content = UNMutableNotificationContent()
        content.title = "💪 Keep Going!"
        content.body = message
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    /// ✅ **Update Hydration Streak**
    func updateHydrationStreak() {
        let streakKey = "hydrationStreak"
        let lastStreakDateKey = "lastHydrationDate"

        let today = Calendar.current.startOfDay(for: Date())

        if let lastDate = defaults.object(forKey: lastStreakDateKey) as? Date,
           Calendar.current.isDate(lastDate, inSameDayAs: today) {
            return
        }

        totalIntake = defaults.double(forKey: "totalIntakeToday")

        if totalIntake >= 60 {
            let currentStreak = defaults.integer(forKey: streakKey) + 1
            defaults.set(today, forKey: lastStreakDateKey)
            defaults.set(currentStreak, forKey: streakKey)
            defaults.synchronize()
        } else {
            defaults.set(0, forKey: streakKey)
        }
    }
}
