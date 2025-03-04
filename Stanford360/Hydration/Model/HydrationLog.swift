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
    var hydrationOunces: Double
    var timestamp: Date
    
    init(
        hydrationOunces: Double,
        timestamp: Date,
        id: String? = UUID().uuidString
    ) {
        self.id = id
        self.hydrationOunces = hydrationOunces
        self.timestamp = timestamp
    }
}
