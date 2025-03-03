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
import Spezi

/// Represents a child's daily physical activity session.
struct Activity: Identifiable, Codable, @unchecked Sendable {
    @DocumentID var id: String?
    var date: Date
    var steps: Int
    var activeMinutes: Int
    var caloriesBurned: Int
    var activityType: String
    var userId: String?
    
    init(
        date: Date,
        steps: Int,
        activeMinutes: Int,
        caloriesBurned: Int,
        activityType: String,
        id: String? = UUID().uuidString,
        userId: String? = nil
    ) {
        self.id = id
        self.date = date
        self.steps = steps
        self.activeMinutes = activeMinutes
        self.caloriesBurned = caloriesBurned
        self.activityType = activityType
        self.userId = userId
    }
    
    enum CodingKeys: String, CodingKey {
        case date, steps, activeMinutes, caloriesBurned, activityType, userId
    }
}
