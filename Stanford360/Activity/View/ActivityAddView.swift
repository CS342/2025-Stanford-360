//
//  ActivityAddView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/10/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct ActivityAddView: View {
	@Environment(ActivityManager.self) private var activityManager
    @Environment(Stanford360Standard.self) private var standard
    @Environment(Stanford360Scheduler.self) var scheduler
    
    // Activity properties that can be initialized for editing
    @State private var activeMinutes: String
    @State private var selectedActivity: String
    @State private var selectedDate: Date
    @State private var showingDateError = false
    @State private var showingAddActivity = false
    private var activityId: String?
	
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                PercentageRing(
                    currentValue: activityManager.getTodayTotalMinutes(),
                    maxValue: 60,
                    iconName: "figure.walk",
                    ringWidth: 25,
                    backgroundColor: Color.activityColorBackground,
                    foregroundColors: [Color.activityColor, Color.activityColorGradient],
                    unitLabel: "minutes",
                    iconSize: 13,
                    showProgressTextInCenter: true
                )
                .frame(width: 210, height: 210) // Fixed dimensions
                .padding(.top, 30)
                
                Text.goalMessage(current: Double(activityManager.getTodayTotalMinutes()), goal: 60, unit: "min")
                    .padding(.top, 10)
                
                // Activity input components
                ActivityPickerView(selectedActivity: $selectedActivity)
                    .padding(.top, 20)
                
                saveNewActivityButton(showingAddActivity: $showingAddActivity)
                    .padding(.bottom, 30)
            }
            .padding(.horizontal)
            
            MilestoneMessageView(unit: "minutes of activity")
                .environmentObject(activityManager.milestoneManager)
                .offset(y: -250)
        }
        .sheet(isPresented: $showingAddActivity) {
            AddActivitySheet(selectedActivity: selectedActivity)
        }
    }
    
    private var saveButtonView: some View {
        ActionButton(
            title: "Save My Activity! 🌟",
            action: {
                Task {
                    await saveNewActivity()
                }
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
    }
    
    init(activity: Activity) {
        self._activeMinutes = State(initialValue: "\(activity.activeMinutes)")
        self._selectedActivity = State(initialValue: activity.activityType)
        self._selectedDate = State(initialValue: activity.date)
        self.activityId = activity.id
    }
    
    private func saveNewActivity() async {
        let minutes = Int(activeMinutes) ?? 0
        let estimatedSteps = activityManager.getStepsFromMinutes(minutes)
        
        let newActivity = Activity(
            date: Date(),
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
    
    func saveNewActivityButton(showingAddActivity: Binding<Bool>) -> some View {
        SaveActivityButton(
            showingAddActivity: showingAddActivity,
            selectedActivity: showingAddActivity.wrappedValue ? "Walking" : nil,
            minutes: showingAddActivity.wrappedValue ? "0" : nil
        )
    }
}

#Preview {
	@Previewable @State var activityManager = ActivityManager(activities: activitiesData)
    ActivityAddView()
		.environment(activityManager)
}
