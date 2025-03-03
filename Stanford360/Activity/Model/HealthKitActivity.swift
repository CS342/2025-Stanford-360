//
//  HealthKitActivity.swift
//  Stanford360
//
//  Created by Elsa Bismuth on 13/02/2025.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT

import Foundation

struct HealthKitActivity: Sendable {
    var date: Date
    var steps: Int
    var activeMinutes: Int
    var activityType: String
    
    func toActivity() -> Activity {
        Activity(
            date: date,
            steps: steps,
            activeMinutes: activeMinutes,
            activityType: activityType
        )
    }
}
