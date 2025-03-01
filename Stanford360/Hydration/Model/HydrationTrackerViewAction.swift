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
            await updateFirestoreLog(newTotalIntake, newStreak, isStreakUpdated, lastHydrationDate)

            totalIntake = newTotalIntake
            streak = newStreak
            
            let updatedWeeklyData = await standard.fetchWeeklyHydrationData()
            let updatedMonthlyData = await standard.fetchMonthlyHydrationData()
            withAnimation {
                weeklyData = updatedWeeklyData
                monthlyData = updatedMonthlyData
            }
            
            await hydrationScheduler.userLoggedWaterIntake()

            displayMilestoneMessage(newTotalIntake: newTotalIntake, lastMilestone: fetchedLog?.lastTriggeredMilestone ?? 0)
        } catch {
            print("❌ Error updating hydration log: \(error)")
        }
        selectedAmount = nil
        intakeAmount = ""
    }
    
    private func updateFirestoreLog(_ newTotalIntake: Double, _ newStreak: Int, _ isStreakUpdated: Bool, _ lastHydrationDate: Date) async {
        let updatedLog = HydrationLog(
            amountOz: newTotalIntake,
            streak: newStreak,
            lastTriggeredMilestone: max(totalIntake, newTotalIntake),
            lastHydrationDate: lastHydrationDate,
            isStreakUpdated: isStreakUpdated
        )

        await standard.addOrUpdateHydrationLog(hydrationLog: updatedLog)
    }
    
    // MARK: - Helper Function: Display Milestone Message
    func displayMilestoneMessage(newTotalIntake: Double, lastMilestone: Double) {
        let milestoneData = checkMilestones(newTotalIntake: newTotalIntake, lastMilestone: lastMilestone)
        
        if let message = milestoneData.message {
            withAnimation {
                self.milestoneMessage = message
                self.isSpecialMilestone = milestoneData.isSpecial
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    self.milestoneMessage = nil
                    self.isSpecialMilestone = false
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

            // 🔹 Fetch Weekly Data Again to Refresh Graph
            let updatedWeeklyData = await standard.fetchWeeklyHydrationData()
            withAnimation {
                weeklyData = updatedWeeklyData
            }
        } catch {
            print("❌ Error fetching hydration data: \(error)")
        }
    }

    // MARK: - Check Milestones
    func checkMilestones(newTotalIntake: Double, lastMilestone: Double) -> (message: String?, isSpecial: Bool) {
        var latestMessage: String?
        var isSpecialMilestone = false

        for milestone in stride(from: 20, through: newTotalIntake, by: 20) where milestone > lastMilestone {
            if milestone == 60 && lastMilestone < 60 {
                latestMessage = "🎉🎉 Amazing! You've reached 60 oz today! Keep up the great work! 🎉🎉"
                isSpecialMilestone = true
            } else {
                latestMessage = "🎉 Great job! You've reached \(Int(milestone)) oz of water today!"
                isSpecialMilestone = false
            }
        }

        return (latestMessage, isSpecialMilestone)
    }
}
