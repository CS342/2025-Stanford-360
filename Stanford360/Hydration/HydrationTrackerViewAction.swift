//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI
import UserNotifications

extension HydrationTrackerView {
    // MARK: - Log Water Intake Action
    func logWaterIntake() async {
        guard let amount = Double(intakeAmount), amount > 0 else {
            errorMessage = "❌ Please enter a valid water intake amount."
            return
        }

        errorMessage = nil

        do {
            let fetchedLog = try await standard.fetchHydrationLog()
            var newTotalIntake = amount
            var newStreak = streak ?? 0
            let lastHydrationDate = Date()
            var isStreakUpdated = fetchedLog?.isStreakUpdated ?? false

            // Update total intake and streak
            if let existingLog = fetchedLog {
                newTotalIntake += existingLog.amountOz
                if newTotalIntake >= 60 && !isStreakUpdated {
                    newStreak += 1
                    isStreakUpdated = true
                    streakJustUpdated = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        streakJustUpdated = false
                    }
                }
            } else {
                if newTotalIntake >= 60 {
                    newStreak += 1
                    isStreakUpdated = true
                    streakJustUpdated = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        streakJustUpdated = false
                    }
                }
            }

            // Update Firestore
            let updatedLog = HydrationLog(
                date: Date(),
                amountOz: newTotalIntake,
                streak: newStreak,
                lastTriggeredMilestone: fetchedLog?.lastTriggeredMilestone ?? 0,
                lastHydrationDate: lastHydrationDate,
                isStreakUpdated: isStreakUpdated
            )
            
            await standard.addOrUpdateHydrationLog(hydrationLog: updatedLog)

            totalIntake = newTotalIntake
            streak = newStreak
            
            scheduleHydrationReminder()
            
            displayMilestoneMessage(newTotalIntake: updatedLog.amountOz, lastMilestone: fetchedLog?.lastTriggeredMilestone ?? 0)
        } catch {
            print("❌ Error updating hydration log: \(error)")
        }
        selectedAmount = nil
        intakeAmount = ""
    }
    
    // MARK: - Helper Function: Display Milestone Message
    func displayMilestoneMessage(newTotalIntake: Double, lastMilestone: Double) {
        let milestoneMessage = checkMilestones(newTotalIntake: newTotalIntake, lastMilestone: lastMilestone)
        if let message = milestoneMessage {
            withAnimation {
                self.milestoneMessage = message
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    self.milestoneMessage = nil
                }
            }
        }
    }

    // MARK: - Fetch Hydration Data
    func fetchHydrationData() async {
        do {
            let fetchedLog = try await standard.fetchHydrationLog()
            if streak == nil {
                let yesterdayStreak = await standard.fetchYesterdayStreak()
                streak = yesterdayStreak
            }

            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())

            if let log = fetchedLog, calendar.isDate(log.lastHydrationDate, inSameDayAs: today) {
                totalIntake = log.amountOz
                streak = log.streak
            }
        } catch {
            print("❌ Error fetching hydration data: \(error)")
        }
    }

    // MARK: - Check Milestones
    func checkMilestones(newTotalIntake: Double, lastMilestone: Double) -> String? {
        var latestMessage: String?

        for milestone in stride(from: 20, through: newTotalIntake, by: 20) where milestone > lastMilestone {
            latestMessage = milestone == 60
                ? "🎉🎉 Amazing! You've reached 60 oz today! Keep up the great work! 🎉🎉"
                : "🎉 Great job! You've reached \(Int(milestone)) oz of water today!"
        }

        return latestMessage
    }
    
    // MARK: - Hydration Reminder Notifications
    func scheduleHydrationReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["hydrationReminder"])

        let content = UNMutableNotificationContent()
        content.title = "💧 Stay Hydrated!"
        content.body = "You haven't logged any water intake in the last 4 hours. Drink up!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 4 * 60 * 60, repeats: false)
        let request = UNNotificationRequest(identifier: "hydrationReminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
}
