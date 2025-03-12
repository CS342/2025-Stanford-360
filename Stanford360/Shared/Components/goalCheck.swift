//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

extension Text {
    @ViewBuilder
    static func goalMessage(current: Double, goal: Double, unit: String) -> some View {
        if current < goal {
            Text("You need \(String(format: "%.1f", goal - current)) \(unit) more to reach your goal!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .accessibilityIdentifier("goalMessageLabel")
        } else {
            Text("🎉 Goal Reached! Keep It Up! 🎉")
                .font(.subheadline)
                .foregroundColor(.green)
                .bold()
                .accessibilityIdentifier("goalMessageLabel")
        }
    }
}
