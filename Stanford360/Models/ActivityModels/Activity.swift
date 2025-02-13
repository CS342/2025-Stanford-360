//
//  Activity.swift
//  Stanford360
//
//  Created by Elsa Bismuth on 29/01/2025.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT

import FirebaseFirestore
import Foundation

/// Represents a child's daily physical activity session.
struct Activity: Identifiable, Codable {
    @DocumentID var id: String?
    var date: Date
    var steps: Int
    var activeMinutes: Int
    var caloriesBurned: Int
    var activityType: String
    
    init(date: Date, steps: Int, activeMinutes: Int, caloriesBurned: Int, activityType: String, id: String? = UUID().uuidString) {
        self.id = id
        self.date = date
        self.steps = steps
        self.activeMinutes = activeMinutes
        self.caloriesBurned = caloriesBurned
        self.activityType = activityType
    }
    
    /// Converts steps to active minutes (1000 steps ≈ 10 min).
    static func convertStepsToMinutes(steps: Int) -> Int {
        steps / 100
    }
}
