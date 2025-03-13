//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI

class MilestoneManager: ObservableObject {
    @Published var milestoneMessage: String?
    @Published var isSpecialMilestone: Bool = false

    // MARK: - Check Milestones with Custom Unit
    func checkMilestones(
        newTotal: Double,
        lastMilestone: Double,
        unit: String,
        streak: Int,
        milestoneInterval: Double = 20,
        specialMilestone: Double = 60
    ) -> (message: String?, isSpecial: Bool) {
        var latestMessage: String?
        var isSpecial = false

        for milestone in stride(from: milestoneInterval, through: newTotal, by: milestoneInterval) where milestone > lastMilestone {
            if milestone == specialMilestone && lastMilestone < specialMilestone {
                latestMessage = "Amazing! You've reached \(Int(specialMilestone)) \(unit) today! \(streak) days in a row! Keep it going!"
                isSpecial = true
            } else {
                latestMessage = "Great job! You've reached \(Int(milestone)) \(unit) today!"
                isSpecial = false
            }
        }
        return (latestMessage, isSpecial)
    }

    // MARK: - Display Milestone Message
    @MainActor
    func displayMilestoneMessage(
        newTotal: Double,
        lastMilestone: Double,
        unit: String,
        streak: Int,
        milestoneInterval: Double = 20,
        specialMilestone: Double = 60
    ) {
        let milestoneData = checkMilestones(
            newTotal: newTotal,
            lastMilestone: lastMilestone,
            unit: unit,
            streak: streak,
            milestoneInterval: milestoneInterval,
            specialMilestone: specialMilestone
        )

        if let message = milestoneData.message {
            withAnimation {
                self.milestoneMessage = message
                self.isSpecialMilestone = milestoneData.isSpecial
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                guard let self = self else {
                    return
                }
                withAnimation {
                    self.milestoneMessage = nil
                    self.isSpecialMilestone = false
                }
            }
        }
    }

    // MARK: - Get Latest Milestone
    func getLatestMilestone(total: Double, milestoneInterval: Double = 20) -> Double {
        Double((Int(total) / Int(milestoneInterval)) * Int(milestoneInterval))
    }
}
