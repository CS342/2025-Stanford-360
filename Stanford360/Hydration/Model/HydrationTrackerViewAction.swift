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

		let hydrationLog = HydrationLog(hydrationOunces: amount, timestamp: Date())
		hydrationManager.hydration.append(hydrationLog)
		await standard.storeHydrationLog(hydrationLog)
		
		errorMessage = nil
		let now = Date()
		let lastRecordedMilestone = hydrationManager.getLatestMilestone()
        let todayHydrationOunces = hydrationManager.getTodayTotalOunces()
        await hydrationScheduler.rescheduleHydrationNotifications()

        // Check and display milestone messages
        displayMilestoneMessage(newTotalIntake: todayHydrationOunces, lastMilestone: lastRecordedMilestone)

        selectedAmount = nil
        intakeAmount = ""
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
