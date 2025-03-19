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
	
	// Activity properties that can be initialized for editing
	@State private var activeMinutes: String
	@State private var selectedActivity: String
	@State private var selectedDate: Date
	@State private var showingAddActivity = false
	
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
				.frame(height: 210)
				.padding(.top, 30)
				
				Text.goalMessage(current: Double(activityManager.getTodayTotalMinutes()), goal: 60, unit: "min")
					.padding(.top, 10)

				Spacer()
				
				VStack {
					// Activity input components
					ActivityPickerView(selectedActivity: $selectedActivity)
						.padding()
					
					HStack {
						saveNewActivityButton(showingAddActivity: $showingAddActivity)
						
						ActivityRecallButton()
						.offset(x: -10)
					}
				}
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
	
	// MARK: - Initializers
	init(selectedActivity: String = "Walking", activeMinutes: String = "", selectedDate: Date = Date()) {
		self._selectedActivity = State(initialValue: selectedActivity)
		self._activeMinutes = State(initialValue: activeMinutes)
		self._selectedDate = State(initialValue: selectedDate)
	}
	
	func saveNewActivityButton(showingAddActivity: Binding<Bool>) -> some View {
		SaveActivityButton(
			showingAddActivity: showingAddActivity
		)
	}
}

#Preview {
	@Previewable @State var activityManager = ActivityManager(activities: activitiesData)
	ActivityAddView()
		.environment(activityManager)
}
