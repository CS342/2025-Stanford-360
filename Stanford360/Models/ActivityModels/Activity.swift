//
//  Activity.swift
//  Stanford360
//
//  Created by Elsa Bismuth on 29/01/2025.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT

import Foundation

/// Represents a child's daily physical activity session.
struct Activity: Identifiable, Codable {
    var id: UUID
    var userID: UUID
    var date: Date
    var steps: Int
    var activeMinutes: Int
    var caloriesBurned: Int
    var activityType: String
    
    init(id: UUID, userID: UUID, date: Date, steps: Int, activeMinutes: Int, caloriesBurned: Int, activityType: String) {
        self.id = UUID()
        self.userID = userID
        self.date = date
        self.steps = steps
        self.activeMinutes = activeMinutes
        self.caloriesBurned = caloriesBurned
        self.activityType = activityType
    }
    
    /// Converts steps to active minutes (1000 steps ≈ 10 min).
    static func convertStepsToMinutes(steps: Int) -> Int {
        steps / 1000 * 10
    }
    
    /// Converts `Activity` to Firebase Dictionary format.
    func toDictionary() -> [String: Any] {[
            "id": id.uuidString,
            "userID": userID.uuidString,
            "date": date.timeIntervalSince1970,
            "steps": steps,
            "activeMinutes": activeMinutes,
            "caloriesBurned": caloriesBurned,
            "activityType": activityType
    ]}
}
