//
//  ActivityRowView.swift
//  Stanford360
//
//  Created by Elsa Bismuth on 03/02/2025.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT

import SwiftUI

/// Extracted Row View
struct ActivityRowView: View {
    let activity: Activity

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(activity.date.formatted(date: Date.FormatStyle.DateStyle.abbreviated, time: Date.FormatStyle.TimeStyle.omitted))")
                .font(.headline)
            Text("🚶 Steps: \(activity.steps)")
            Text("🔥 Calories: \(activity.caloriesBurned)")
            Text("⏳ Minutes: \(activity.activeMinutes)")
            Text("🏃 Activity: \(activity.activityType)")
        }
    }
}

#Preview {
    let activity = Activity(
        date: Date(),
        steps: 5000,
        activeMinutes: 50,
        caloriesBurned: 234,
        activityType: "Biking"
    )
    ActivityRowView(activity: activity)
}
