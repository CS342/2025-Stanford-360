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
	@Environment(Stanford360Scheduler.self) private var scheduler
    @Environment(Stanford360Standard.self) var standard
    
    @State var intakeAmount: String = ""
    @State var errorMessage: String?
    @State var milestoneMessage: String?
    @State var isSpecialMilestone: Bool = false
    @State var selectedAmount: Double?
    @State var streak: Int?

    var body: some View {
        VStack(spacing: 10) {
            HydrationAmountSelector(selectedAmount: $selectedAmount, errorMessage: $errorMessage)
            
            HStack(spacing: 10) {
                logButton()
                    .frame(maxWidth: 0.7 * UIScreen.main.bounds.width)
                HydrationRecallButton()
                    .frame(width: 30, height: 30)
                    .alignmentGuide(.firstTextBaseline) { $0[.bottom] }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
                        
            errorDisplay()
        }
        .padding(.horizontal)
        .offset(y: -50)
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
        await scheduler.rescheduleHydrationNotifications()
        hydrationManager.milestoneManager.displayMilestoneMessage(
            newTotal: hydrationManager.getTodayTotalOunces(),
            lastMilestone: lastRecordedMilestone,
            unit: "oz of water"
        )
        selectedAmount = nil
        intakeAmount = ""
    }
}
