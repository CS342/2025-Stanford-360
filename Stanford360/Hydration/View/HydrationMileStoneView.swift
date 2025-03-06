//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct HydrationMilestoneView: View {
    @Binding var milestoneMessage: String?
    @Binding var isSpecialMilestone: Bool

    var body: some View {
        if let message = milestoneMessage {
            Text(message)
                .foregroundColor(isSpecialMilestone ? .orange : .blue)
                .font(.headline)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 2))
                .transition(.scale)
                .accessibilityIdentifier("milestoneMessageLabel")
        } else {
            EmptyView()
        }
    }
}
