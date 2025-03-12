//
//  ActivityControlPanel.swift
//  Stanford360
//
//  Created by Elsa Bismuth on 11/03/2025.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct ActivityControlPanel: View {
    @Environment(Stanford360Standard.self) private var standard
    @Environment(ActivityManager.self) private var activityManager
    @Environment(Stanford360Scheduler.self) var scheduler
    
    // Activity properties
    @State private var activeMinutes: String = ""
    @State private var selectedActivity: String = "Walking"
    @State private var selectedDate: Date = Date()
    @State private var showingDateError = false
    @State private var showingSuccessMessage = false
    
    var body: some View {
        VStack(spacing: 15) {
            activityPickerSection
            dateAndMinutesSection
            saveButton
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .cornerRadius(12)
        .shadow(radius: 1)
        .alert("Invalid Date", isPresented: $showingDateError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please select a date that isn't in the future.")
        }
        .alert("Activity Saved", isPresented: $showingSuccessMessage) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your activity has been recorded successfully!")
        }
    }
    
    private var dateAndMinutesSection: some View {
        HStack(spacing: 15) {
            // Date picker section
            VStack(alignment: .leading, spacing: 5) {
                Text("Date")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                DatePicker(
                    "Activity Date",
                    selection: $selectedDate,
                    in: ...Date(),
                    displayedComponents: [.date]
                )
                .datePickerStyle(.compact)
                .labelsHidden()
            }
            .frame(maxWidth: .infinity)
            
            // Minutes input section
            VStack(alignment: .leading, spacing: 5) {
                Text("Minutes")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                TextField("Minutes", text: $activeMinutes)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .frame(height: 34)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 10)
    }
    
    private var activityPickerSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Activity Type")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 10)

            let activities = [
                ("Walking", "figure.walk"),
                ("Running", "figure.run"),
                ("Dancing", "figure.dance"),
                ("Sports", "soccerball"),
                ("PE", "person.3"),
                ("Other", "questionmark")
            ]

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(activities, id: \.0) { activity in
                    ActivityButtonView(activityName: activity.0, iconName: activity.1, selectedActivity: $selectedActivity)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var saveButton: some View {
        Button {
            Task {
                await saveNewActivity()
            }
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .accessibilityLabel("Add button with plus symbol")
                Text("Add Activity")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(activeMinutes.isEmpty ? Color.gray : Color.blue)
            )
        }
        .disabled(activeMinutes.isEmpty)
        .padding(.horizontal, 10)
    }
    
    private func getStepsFromMinutes(_ minutes: Int) -> Int {
        minutes * 100
    }
    
    private func saveNewActivity() async {
        // Validate date isn't in the future
        guard selectedDate <= Date() else {
            showingDateError = true
            return
        }
        
        let minutes = Int(activeMinutes) ?? 0
        let estimatedSteps = getStepsFromMinutes(minutes)
        
        let newActivity = Activity(
            date: selectedDate,
            steps: estimatedSteps,
            activeMinutes: minutes,
            activityType: selectedActivity
        )
        
        let prevActivityMinutes = activityManager.getTodayTotalMinutes()
        let lastRecordedMilestone = activityManager.getLatestMilestone()
        activityManager.activities.append(newActivity)
        let activityMinutes = activityManager.getTodayTotalMinutes()
        await standard.addActivityToFirestore(newActivity)
        await scheduler.handleNotificationsOnLoggedActivity(prevActivityMinutes: prevActivityMinutes, newActivityMinutes: activityMinutes)
        activityManager.milestoneManager.displayMilestoneMessage(
            newTotal: Double(activityManager.getTodayTotalMinutes()),
            lastMilestone: lastRecordedMilestone,
            unit: "minutes of activity"
        )
    }
}

#Preview {
    ActivityControlPanel()
        .environment(ActivityManager())
        .environment(PatientManager())
        .environment(Stanford360Standard())
        .environment(Stanford360Scheduler())
}
