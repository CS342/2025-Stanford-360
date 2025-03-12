//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI
import UIKit

struct MilestoneMessageView: View {
    @EnvironmentObject var milestoneManager: MilestoneManager
    let unit: String
    
    var body: some View {
        if let message = milestoneManager.milestoneMessage {
            ZStack {
                ConfettiView(isSpecial: milestoneManager.isSpecialMilestone)

                MilestoneContentView(
                    message: message,
                    isSpecialMilestone: milestoneManager.isSpecialMilestone
                )
                .frame(maxWidth: 300)
            }
            .transition(.scale)
            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: milestoneManager.milestoneMessage)
            .accessibilityIdentifier("\(unit)MilestoneMessageLabel")
        } else {
            EmptyView()
        }
    }
}
