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
    @Environment(ActivityManager.self) private var activityManager
    @Environment(Stanford360Standard.self) private var standard
    @State private var showingAddActivitySheet = false
    @State private var isPerformingAction = false

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
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                showingAddActivitySheet = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
            .disabled(isPerformingAction)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                isPerformingAction = true
                Task {
                    await standard.deleteActivity(activity)
                    var updatedActivities = activityManager.activities
                    updatedActivities.removeAll { $0.id == activity.id }
                    activityManager.activities = updatedActivities
                    isPerformingAction = false
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .disabled(isPerformingAction)
        }
        .sheet(isPresented: $showingAddActivitySheet) {
            // Use the AddActivitySheet with the activity for editing
            AddActivitySheet(activity: activity)
        }
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
