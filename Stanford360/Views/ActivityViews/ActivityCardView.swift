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
                .font(.title3.bold())
            
            Spacer()
            
            // Minutes with emphasis
            Text("\(activity.activeMinutes) min")
                .font(.title3)
                .foregroundStyle(.blue)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(radius: 2)
        )
    }
}

#Preview {
    let sampleActivity = Activity(
        date: Date(),
        steps: 5000,
        activeMinutes: 45,
        caloriesBurned: 200,
        activityType: "Running"
    )
    
    return ActivityCardView(activity: sampleActivity)
        .padding()
}
