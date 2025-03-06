//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct HydrationTodayView: View {
    @Environment(HydrationManager.self) private var hydrationManager

    var body: some View {
        VStack(spacing: 20) {
            PercentageRing(
                currentValue: Int(hydrationManager.getTodayTotalOunces()),
                maxValue: 60,
                iconName: "drop.fill",
                ringWidth: 25,
                backgroundColor: .hydrationColorBackground,
                foregroundColors: [.hydrationColor, .hydrationColorGradient],
                unitLabel: "ounces",
                iconSize: 13,
                showProgressTextInCenter: true
            )
            .frame(height: 210)
            .padding(.top, 15)

            // HydrationStreakView()
        }
    }
}
