//
//  AddActivitySheetView.swift
//  Stanford360
//
//  Created by Elsa Bismuth on 13/02/2025.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT

import SwiftUI

struct AddActivitySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Stanford360Standard.self) private var standard
    @Bindable var activityManager: ActivityManager
    @State private var activeMinutes = ""
    @State private var selectedActivity = "Walking 🚶‍♂️"
    @State private var selectedDate = Date()
    @State private var showingDateError = false
    
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
        Text("Add Your Activity! 🎯")
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
                await saveActivityToView()
            }
            dismiss()
        }) {
            Text("Save My Activity! 🌟")
                .font(.title3.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.blue)
                )
        }
        .padding()
        .disabled(activeMinutes.isEmpty)
    }
    
    private func saveActivityToView() async {
        // Validate date isn't in the future
        guard selectedDate <= Date() else {
            showingDateError = true
            return
        }
        
        let minutes = Int(activeMinutes) ?? 0
        let estimatedSteps = minutes * 100
        
        let newActivity = Activity(
            date: selectedDate,  // Use selected date instead of current date
            steps: estimatedSteps,
            activeMinutes: minutes,
            caloriesBurned: estimatedSteps / 10,
            activityType: selectedActivity
        )
        
        activityManager.activities.append(newActivity)
        await standard.addActivityToFirestore(activity: newActivity)
    }
}

#Preview {
    AddActivitySheet(activityManager: ActivityManager())
        .environment(Stanford360Standard())
}
