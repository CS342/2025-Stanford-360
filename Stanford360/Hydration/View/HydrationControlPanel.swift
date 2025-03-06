//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct HydrationControlPanel: View {
    @Environment(HydrationManager.self) private var hydrationManager
    @Environment(HydrationScheduler.self) private var hydrationScheduler
    @Environment(Stanford360Standard.self) var standard
    
    @State var intakeAmount: String = ""
    @State var errorMessage: String?
    @State var milestoneMessage: String?
    @State var isSpecialMilestone: Bool = false
    @State var selectedAmount: Double?
    @State var streak: Int?
    
    var todayIntake: Double {
        hydrationManager.getTodayTotalOunces()
    }

    var body: some View {
        VStack(spacing: 10) {
            HydrationAmountSelector(selectedAmount: $selectedAmount, errorMessage: $errorMessage)
            logButton()
            errorDisplay()
            suggestionDisplay()
            HydrationMilestoneView(milestoneMessage: $milestoneMessage, isSpecialMilestone: $isSpecialMilestone)
        }
        .padding(.horizontal)
    }

    // MARK: - Log Button
    private func logButton() -> some View {
        Button(action: {
            guard let selected = selectedAmount else {
                errorMessage = "❌ Please select an amount first."
                return
            }
            intakeAmount = String(selected)
            Task {
                await logWaterIntake()
            }
        }) {
            Text("Log Water Intake")
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [
                            Color.blue,
                            Color.blue.opacity(0.8)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(radius: 3)
        }
        .padding(.horizontal)
        .accessibilityIdentifier("logWaterIntakeButton")
        .accessibilityLabel("Log your water intake")
    }

    // MARK: - Error Display
    private func errorDisplay() -> some View {
        Group {
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.subheadline)
                    .accessibilityIdentifier("errorMessageLabel")
            }
        }
    }

    // MARK: - Goal Suggestion Display
    private func suggestionDisplay() -> some View {
        if todayIntake < 60 {
            return AnyView(
                Text("You need \(String(format: "%.1f", 60 - todayIntake)) oz more to reach your goal!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .accessibilityIdentifier("suggestionLabel")
            )
        } else {
            return AnyView(
                Text("🎉 Goal Reached! Stay Hydrated! 🎉")
                    .font(.subheadline)
                    .foregroundColor(.green)
                    .bold()
                    .accessibilityIdentifier("goalReachedLabel")
            )
        }
    }

    // MARK: - Log Water Intake Function
    func logWaterIntake() async {
        guard let amount = Double(intakeAmount), amount > 0 else {
            errorMessage = "❌ Please enter a valid water intake amount."
            return
        }
        
        let lastRecordedMilestone = hydrationManager.getLatestMilestone()
        let hydrationLog = HydrationLog(hydrationOunces: amount, timestamp: Date())
        hydrationManager.hydration.append(hydrationLog)
        await standard.storeHydrationLog(hydrationLog)

        errorMessage = nil
        streak = hydrationManager.streak
        await hydrationScheduler.rescheduleHydrationNotifications()
        displayMilestoneMessage(newTotalIntake: todayIntake, lastMilestone: lastRecordedMilestone)

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
