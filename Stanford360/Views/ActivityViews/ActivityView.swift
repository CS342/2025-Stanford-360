//
//  ActivityView.swift
//  Stanford360
//
//  Created by Elsa Bismuth on 30/01/2025.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT

import SwiftUI

/// Simple UI for tracking kids' activity.
struct ActivityView: View {
    @Bindable private var activityManager = ActivityManager()
    @State private var steps: String = ""
    @State private var activityType: String = ""

    var body: some View {
        NavigationView {
            VStack {
                activityListView
                activityFormView
            }
        }
    }

    /// Extracted View for displaying logged activities
    private var activityListView: some View {
        List {
            ForEach(activityManager.activities) { activity in
                ActivityRowView(activity: activity)
            }
            .onDelete { indexSet in
                activityManager.activities.remove(atOffsets: indexSet)
            }
        }
        .navigationTitle("Kids' Activity Tracker")
    }

    /// Extracted View for input form
    private var activityFormView: some View {
        Form {
            TextField("Steps", text: $steps)
                .keyboardType(.numberPad)

            TextField("Activity Type", text: $activityType)

            Button("Log Activity") {
                logNewActivity()
            }
        }
        .padding()
    }

    /// Function to handle logging a new activity
    private func logNewActivity() {
        let stepsInt = Int(steps) ?? 0
        let newActivity = Activity(
            date: Date(),
            steps: stepsInt,
            activeMinutes: Activity.convertStepsToMinutes(steps: stepsInt),
            caloriesBurned: stepsInt / 10, // Approximate formula
            activityType: activityType
        )
        activityManager.logActivity(newActivity)
        steps = ""
        activityType = ""
    }
}

#Preview {
	ActivityView()
}
