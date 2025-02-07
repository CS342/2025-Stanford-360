//
//  ActivityView.swift
//  Stanford360
//
//  Created by Elsa Bismuth on 30/01/2025.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT

import FirebaseAuth
import SwiftUI

/// Simple UI for tracking kids' activity.
struct ActivityView: View {
    @State private var activityManager = ActivityManager()
    @State private var steps: String = ""
    @State private var activityType: String = ""
    private var motivationMessage: String {
        activityManager.triggerMotivation()
    }
    @Environment(Stanford360Standard.self) private var standard


    var body: some View {
        NavigationView {
            VStack {
                activityListView
                activityFormView
                
                Text(motivationMessage)
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding()
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
                Task {
                    await logActivityToFirestore()
                }
            }
        }
    }

    /// Function to handle logging a new activity
    private func logActivityToFirestore() async {
        let stepsInt = Int(steps) ?? 0
        do {
            let newActivity = Activity(
                date: Date(),
                steps: stepsInt,
                activeMinutes: Activity.convertStepsToMinutes(steps: stepsInt),
                caloriesBurned: stepsInt / 10,
                activityType: activityType
            )
            activityManager.logActivityToView(newActivity)
            try await standard.store(activity: newActivity)
            steps = ""
            activityType = ""
        } catch {
            print("Error logging activity—user may not be authenticated: \(error)")
        }
    }
}

/// **Preview Provider with Fake Data**
struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        let mockManager = ActivityManager()
        mockManager.activities = [
            Activity(
                date: Date(),
                steps: 3000,
                activeMinutes: 30,
                caloriesBurned: 100,
                activityType: "Running"
            ),
            Activity(
                date: Date(),
                steps: 5000,
                activeMinutes: 50,
                caloriesBurned: 234,
                activityType: "Biking"
            )
        ]
        return ActivityView()
    }
}
