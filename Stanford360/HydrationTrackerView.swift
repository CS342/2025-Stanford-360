//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct HydrationTrackerView: View {
    @ObservedObject var hydrationTracker = HydrationTracker()
    @State private var intakeAmount: String = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 20) {
            headerView()
            intakeDisplay()
            inputField()
            errorDisplay()
            logButton()
            suggestionDisplay()
            Spacer()
        }
        .padding()
    }

    /// **Header View**
    private func headerView() -> some View {
        Text("💧 Hydration Tracker")
            .font(.largeTitle)
            .bold()
            .padding()
            .accessibilityLabel("Hydration Tracker Header")
    }

    /// **Intake & Streak Display**
    private func intakeDisplay() -> some View {
        VStack(spacing: 10) {
            Text("Total Intake: \(String(format: "%.1f", hydrationTracker.totalIntake)) oz")
                .font(.title2)
                .foregroundColor(hydrationTracker.totalIntake >= 60 ? .green : .primary)
                .accessibilityIdentifier("totalIntakeLabel")

            if hydrationTracker.streak > 0 {
                Text("🔥 Streak: \(hydrationTracker.streak) days!")
                    .font(.headline)
                    .foregroundColor(.orange)
                    .accessibilityIdentifier("streakLabel")
            }
        }
    }

    /// **User Input Field**
    private func inputField() -> some View {
        TextField("Enter intake (oz)", text: $intakeAmount)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(.decimalPad)
            .padding()
            .accessibilityIdentifier("intakeInputField")
    }

    /// **Error Display**
    private func errorDisplay() -> some View {
        Group {
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.subheadline)
                    .accessibilityIdentifier("errorMessageLabel")
            } else {
                Text("")
                    .accessibilityHidden(true)
            }
        }
    }
    /// **Suggestion Display**
    private func suggestionDisplay() -> some View {
        if hydrationTracker.totalIntake < 60 {
            Text("You need \(String(format: "%.1f", 60 - hydrationTracker.totalIntake)) oz more to reach your goal!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .accessibilityIdentifier("suggestionLabel")
        } else {
            Text("🎉 Goal Reached! Stay Hydrated! 🎉")
                .font(.subheadline)
                .foregroundColor(.green)
                .accessibilityIdentifier("goalReachedLabel")
        }
    }

    /// **Log Button**
    private func logButton() -> some View {
        Button(action: logWaterIntake) {
            Text("Log Water Intake")
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding(.horizontal)
        .accessibilityIdentifier("logWaterIntakeButton")
        .accessibilityLabel("Log your water intake")
    }

    /// **Log Water Intake Action**
    private func logWaterIntake() {
        guard let amount = Double(intakeAmount), amount > 0 else {
            errorMessage = "❌ Please enter a valid water intake amount."
            return
        }

        errorMessage = nil
        hydrationTracker.logWaterIntake(intakeAmount: amount) { success in
            if !success {
                errorMessage = "❌ Failed to log intake."
            }
        }

        intakeAmount = ""
    }
}

// MARK: - Preview
#Preview {
    HydrationTrackerView()
}
