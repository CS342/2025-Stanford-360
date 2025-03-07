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
    @Environment(ActivityScheduler.self) var activityScheduler
    
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
            VStack(spacing: 25) {
                headerView
                activityPickerSection
                datePickerSection
                minutesInputSection
                saveButton
                Spacer()
            }
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
    
    private var headerView: some View {
        Text(isEditing ? "Edit Your Activity! 📝" : "Add Your Activity! 🎯")
            .font(.title)
            .bold()
            .padding(.top)
    }
    
    private var datePickerSection: some View {
        VStack(alignment: .leading) {
            Text("When did you do it?")
                .font(.headline)
            
            DatePicker(
                "Activity Time",
                selection: $selectedDate,
                in: ...Date(),  // Restricts selection to past dates
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.compact)
            .padding(.vertical, 5)
        }
        .padding()
    }
    
    private var activityPickerSection: some View {
        VStack(alignment: .leading) {
            Text("What did you do?")
                .font(.headline)

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
    
    private var minutesInputSection: some View {
        VStack(alignment: .leading) {
            Text("How many minutes?")
                .font(.headline)
            
            TextField("Minutes", text: $activeMinutes)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
                .font(.title3)
            
            Text("Goal: 60 minutes per day")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
    }
    
    private var saveButton: some View {
        Button {
            Task {
                if isEditing {
                    await updateActivity()
                } else {
                    await saveNewActivity()
                }
            }
            dismiss()
        } label: {
            Text(isEditing ? "Update Activity! 🔄" : "Save My Activity! 🌟")
                .font(.title3.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.blue)
                )
        }
        .disabled(activeMinutes.isEmpty)
        .padding()
    }

    // Initializer to accept pre-filled values when creating a new activity
    init(selectedActivity: String = "Walking 🚶‍♂️", activeMinutes: String = "", selectedDate: Date = Date()) {
        self._selectedActivity = State(initialValue: selectedActivity)
        self._activeMinutes = State(initialValue: activeMinutes)
        self._selectedDate = State(initialValue: selectedDate)
        self.activityId = nil
        self.isEditing = false
    }
    
    // Initializer for editing an existing activity
    init(activity: Activity) {
        self._activeMinutes = State(initialValue: "\(activity.activeMinutes)")
        self._selectedActivity = State(initialValue: activity.activityType)
        self._selectedDate = State(initialValue: activity.date)
        self.activityId = activity.id
        self.isEditing = true
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
        activityManager.activities.append(newActivity)
		let activityMinutes = activityManager.getTodayTotalMinutes()
        await standard.addActivityToFirestore(newActivity)
		await activityScheduler.handleNotificationsOnLoggedActivity(prevActivityMinutes: prevActivityMinutes, newActivityMinutes: activityMinutes)
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
//        activityManager.activities.editActivity(updatedActivity)
    }
}

// Preview for adding a new activity
#Preview("Add New Activity") {
    AddActivitySheet()
        .environment(ActivityManager())
        .environment(PatientManager())
        .environment(Stanford360Standard())
}

// Preview for editing an existing activity
#Preview("Edit Activity") {
    let sampleActivity = Activity(
        date: Date(),
        steps: 5000,
        activeMinutes: 45,
        activityType: "Running 🏃‍♂️",
        id: "sample-id"
    )
    
    return AddActivitySheet(activity: sampleActivity)
        .environment(ActivityManager())
        .environment(PatientManager())
        .environment(Stanford360Standard())
}
