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
        let now = Date()

        hydrationManager.addHydrationLog(amount: amount, timestamp: now, previousStreak: streak ?? 0)
        let todayTotalIntake = hydrationManager.getTodayHydrationOunces()
        let (latestStreak, isStreakUpdated) = hydrationManager.calculateStreak(previousStreak: streak ?? 0)
        await updateFirestoreLog(todayTotalIntake, latestStreak, isStreakUpdated, now)

        totalIntake = todayTotalIntake
        streak = latestStreak
        patientManager.updateHydrationOunces(todayTotalIntake)

        let updatedWeeklyData = await standard.fetchWeeklyHydrationData()
        let updatedMonthlyData = await standard.fetchMonthlyHydrationData()
        withAnimation {
            weeklyData = updatedWeeklyData
            monthlyData = updatedMonthlyData
        }

        await hydrationScheduler.userLoggedWaterIntake()
        displayMilestoneMessage(newTotalIntake: todayTotalIntake, lastMilestone: hydrationManager.getLatestLog()?.lastTriggeredMilestone ?? 0)

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
