//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct HydrationRecallButton: View {
    @Environment(HydrationManager.self) private var hydrationManager
    @Environment(Stanford360Standard.self) private var standard

    var body: some View {
        Button(action: {
            Task {
                let today = Calendar.current.startOfDay(for: Date())
                if let lastLog = hydrationManager.hydration.last(where: {
                    Calendar.current.startOfDay(for: $0.timestamp) == today
                }) {
                    await standard.deleteHydrationLog(lastLog)
                    hydrationManager.recallLastIntake()
                } else {
                }
            }
        }) {
            Image(systemName: "arrow.uturn.backward.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(.red)
                .accessibilityLabel("Recall Last Intake")
        }
        .disabled(hydrationManager.getTodayTotalOunces() == 0)
    }
}
