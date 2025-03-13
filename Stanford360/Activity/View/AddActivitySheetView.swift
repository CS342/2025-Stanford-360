//
//  AddActivitySheetView.swift
//  Stanford360
//
//  Created by Elsa Bismuth on 13/02/2025.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT

import SpeziViews
import SwiftUI

struct AddActivitySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Stanford360Standard.self) private var standard
    @Environment(ActivityManager.self) private var activityManager
    @Environment(Stanford360Scheduler.self) var scheduler
    
    // Activity properties that can be initialized for editing
    @State private var activeMinutes: String
    @State private var selectedActivity: String
    @State private var selectedDate: Date
    @State private var showingDateError = false
    
    // For editing, we need the original activity ID
    private var activityId: String?
    private var isEditing: Bool
    
    var body: some View {
        NavigationStack {
            mainContentView
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cancel") { dismiss() }
                    }
                }
                .padding()
                .alert("Invalid Date", isPresented: $showingDateError) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("Please select a date and time that isn't in the future.")
                }
        }
    }
    
    // MARK: - Content Views
    private var mainContentView: some View {
        VStack(spacing: 25) {
//            headerView
//            ActivityPickerView(selectedActivity: $selectedActivity)
            DatePickerView(
                selectedDate: $selectedDate,
                title: "When did you do it?",
                dateRange: ...Date(),
                displayComponents: [.date]
            )
            MinutesInputView(
                minutes: $activeMinutes,
                title: "How many minutes?",
                goalText: "Goal: 60 minutes per day"
            )
            saveButtonView
            Spacer()
        }
    }
    
    private var headerView: some View {
        Text(isEditing ? "Edit Your Activity! 📝" : "Add Your Activity! 🎯")
            .font(.title)
            .bold()
            .padding(.top)
    }
    
    private var saveButtonView: some View {
        ActionButton(
            title: isEditing ? "Update Activity! 🔄" : "Save My Activity! 🌟",
            action: {
                Task {
                    if isEditing {
                        await updateActivity()
                    } else {
                        await saveNewActivity()
                    }
                }
                dismiss()
            },
            isDisabled: activeMinutes.isEmpty
        )
    }
    
    // MARK: - Initializers
    init(selectedActivity: String = "Walking", activeMinutes: String = "", selectedDate: Date = Date()) {
        self._selectedActivity = State(initialValue: selectedActivity)
        self._activeMinutes = State(initialValue: activeMinutes)
        self._selectedDate = State(initialValue: selectedDate)
        self.activityId = nil
        self.isEditing = false
    }
    
    init(activity: Activity) {
        self._activeMinutes = State(initialValue: "\(activity.activeMinutes)")
        self._selectedActivity = State(initialValue: activity.activityType)
        self._selectedDate = State(initialValue: activity.date)
        self.activityId = activity.id
        self.isEditing = true
    }
    
    // MARK: - Helper Methods
    private func saveNewActivity() async {
        // Validate date isn't in the future
        guard selectedDate <= Date() else {
            showingDateError = true
            return
        }
        
        let minutes = Int(activeMinutes) ?? 0
        let estimatedSteps = activityManager.getStepsFromMinutes(minutes)
        
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
        let updatedStreak = activityManager.streak
        await standard.addActivityToFirestore(newActivity)
        await scheduler.handleNotificationsOnLoggedActivity(prevActivityMinutes: prevActivityMinutes, newActivityMinutes: activityMinutes)
        activityManager.milestoneManager.displayMilestoneMessage(
            newTotal: Double(activityManager.getTodayTotalMinutes()),
            lastMilestone: lastRecordedMilestone,
            unit: "minutes of activity",
            streak: updatedStreak
        )
    }
    
    private func updateActivity() async {
        // Validate date isn't in the future
        guard selectedDate <= Date() else {
            showingDateError = true
            return
        }
        
        let minutes = Int(activeMinutes) ?? 0
        let estimatedSteps = minutes * 100
        
        let updatedActivity = Activity(
            date: selectedDate,
            steps: estimatedSteps,
            activeMinutes: minutes,
            activityType: selectedActivity,
            id: activityId
        )
        
        // Use the standard extension method to update in both places
        await standard.updateActivityFirestore(activity: updatedActivity)
        
        // Update in local ActivityManager
        var updatedActivities = activityManager.activities
        if let index = updatedActivities.firstIndex(where: { $0.id == updatedActivity.id }) {
            updatedActivities[index] = updatedActivity
            activityManager.activities = updatedActivities
        }
    }
}

// MARK: - Previews
#Preview("Add New Activity") {
    AddActivitySheet()
        .environment(ActivityManager())
        .environment(PatientManager())
        .environment(Stanford360Standard())
}

#Preview("Edit Activity") {
    let sampleActivity = Activity(
        date: Date(),
        steps: 5000,
        activeMinutes: 45,
        activityType: "Running",
        id: "sample-id"
    )
    
    return AddActivitySheet(activity: sampleActivity)
        .environment(ActivityManager())
        .environment(PatientManager())
        .environment(Stanford360Standard())
}
