//
//  AddActivitySheetView.swift
//  Stanford360
//
//  Created by Elsa Bismuth on 13/02/2025.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT

import SpeziScheduler
import SpeziViews
import SwiftUI

struct AddActivitySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Stanford360Standard.self) private var standard
    @Environment(PatientManager.self) private var patientManager
    @Environment(ActivityManager.self) private var activityManager
    @Environment(Scheduler.self) private var scheduler
    
    // Activity properties that can be initialized for editing
    @State private var activeMinutes: String
    @State private var selectedActivity: String
    @State private var selectedDate: Date
    @State private var showingDateError = false
    
    // For editing, we need the original activity ID
    private var activityId: String?
    private var isEditing: Bool
    
    var viewState: ViewState = .idle
    
    let activityTypes = [
        "Walking 🚶‍♂️", "Running 🏃‍♂️", "Swimming 🏊‍♂️",
        "Dancing 💃", "Basketball 🏀", "Soccer ⚽️",
        "Cycling 🚲", "Other 🌟"
    ]
    
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
            
            Picker("Activity", selection: $selectedActivity) {
                ForEach(activityTypes, id: \.self) { activity in
                    Text(activity)
                }
            }
            .pickerStyle(.wheel)
        }
        .padding()
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
        Button(action: {
            Task {
                if isEditing {
                    await updateActivity()
                } else {
                    await saveNewActivity()
                }
            }
            dismiss()
        }, label: {
            Text(isEditing ? "Update Activity! 🔄" : "Save My Activity! 🌟")
                .font(.title3.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.blue)
                )
        })
        .padding()
        .disabled(activeMinutes.isEmpty)
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
    
    private mutating func saveNewActivity() async {
        // Validate date isn't in the future
        guard selectedDate <= Date() else {
            showingDateError = true
            return
        }
        
        let minutes = Int(activeMinutes) ?? 0
        let estimatedSteps = minutes * 100
        
        let newActivity = Activity(
            date: selectedDate,
            steps: estimatedSteps,
            activeMinutes: minutes,
            activityType: selectedActivity
        )
        
        activityManager.activities.append(newActivity)
        patientManager.updateActivityMinutes(activityManager.getTodayTotalMinutes())
        await standard.addActivityToFirestore(activity: newActivity)
        await scheduleActivityNotifcation(activeMinutes: activityManager.getTodayTotalMinutes())
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
        await standard.updateActivity(activity: updatedActivity, activityManager: activityManager)
        
        // Update patient manager with new totals
        patientManager.updateActivityMinutes(activityManager.getTodayTotalMinutes())
    }
    
    func scheduleActivityNotifcation(activeMinutes: Int) async {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)

        // If it's after 9 PM, don't schedule new reminders
        if hour >= 21 {
            print("⏳ Skipping activity reminder after 9 PM.")
            return
        }

        // If it's before 9 AM, also skip scheduling
        if hour < 9 {
            print("⏳ Skipping activity reminder before 9 AM.")
            return
        }

        // Calculate remaining time to reach 60 minutes
        let remainingMinutes = max(0, 60 - activeMinutes)

        // Schedule a new reminder if goal not reached
        if remainingMinutes > 0 {
            do {
                try scheduler.createOrUpdateTask(
                    id: "activity-reminder",
                    title: "🏃 Keep Moving!",
                    instructions: "You have \(remainingMinutes) minutes left to reach your goal of 60 minutes!",
                    category: Task.Category(rawValue: "Activity"),
                    schedule: .daily(
                        hour: Calendar.current.component(.hour, from: now) + 5,
                        minute: Calendar.current.component(.minute, from: now),
                        startingAt: .now
                    ),
                    scheduleNotifications: true
                )
            } catch {
                print("Failed to schedule activity reminder: \(error.localizedDescription)")
            }
        }
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
