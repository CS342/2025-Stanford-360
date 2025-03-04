//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import Foundation

// MARK: - Hydration Log Model
struct HydrationLog: Identifiable, Codable, @unchecked Sendable {
    @DocumentID var id: String?
    var amountOz: Double
    var streak: Int
    var lastTriggeredMilestone: Double
    var lastHydrationDate: Date
    var isStreakUpdated: Bool

    init(
        amountOz: Double,
        streak: Int,
        lastTriggeredMilestone: Double,
        lastHydrationDate: Date,
        isStreakUpdated: Bool,
        id: String? = UUID().uuidString
    ) {
        self.id = id
        self.amountOz = amountOz
        self.streak = streak
        self.lastTriggeredMilestone = lastTriggeredMilestone
        self.lastHydrationDate = lastHydrationDate
        self.isStreakUpdated = isStreakUpdated
    }
}
