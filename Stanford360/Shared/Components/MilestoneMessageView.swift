//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct MilestoneMessageView: View {
    @EnvironmentObject var milestoneManager: MilestoneManager
    let unit: String

    var body: some View {
        if let message = milestoneManager.milestoneMessage {
            Text(message)
                .foregroundColor(milestoneManager.isSpecialMilestone ? .orange : .blue)
                .font(.headline)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 2))
                .transition(.scale)
                .accessibilityIdentifier("\(unit)MilestoneMessageLabel")
        } else {
            EmptyView()
        }
    }
}
