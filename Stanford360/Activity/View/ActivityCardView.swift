//
//  ActivityCardView.swift
//  Stanford360
//
//  Created by Elsa Bismuth on 13/02/2025.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT

import SwiftUI

struct ActivityCardView: View {
    let activity: Activity

    var body: some View {
        HStack {
            // Activity Type with Emoji
            Text(activity.activityType)
				.font(.system(size: 20))
				.foregroundColor(.textSecondary)
            
            Spacer()
            
            // Minutes with emphasis
            Text("\(activity.activeMinutes) min")
				.font(.system(size: 20))
				.foregroundColor(Color.activityColor)
        }
        .padding(16)
		.background(Color.cardBackground)
		.cornerRadius(15)
		.shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 4)
    }
}

#Preview {
    let sampleActivity = Activity(
        date: Date(),
        steps: 5000,
        activeMinutes: 45,
        activityType: "Running 🏃‍♂️",
        id: "sample-id"
    )
    
    return ActivityCardView(activity: sampleActivity)
        .padding()
        .environment(ActivityManager())
        .environment(Stanford360Standard())
}
