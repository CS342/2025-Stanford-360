//
//  ActivityTimeFrameView.swift
//  Stanford360
//
//  Created by Elsa Bismuth on 13/02/2025.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT

import SwiftUI

struct ActivityTimeFrameView: View {
	@State private var selectedTimeFrame: TimeFrame = .today
	let activityManager: ActivityManager
	
	var body: some View {
		VStack {
			TimeFramePicker(selectedTimeFrame: $selectedTimeFrame)
			
			motivationText
			
			// swipeable tab view
			TabView(selection: $selectedTimeFrame) {
				todayView
					.tag(TimeFrame.today)
				weeklyView
					.tag(TimeFrame.week)
				monthlyView
					.tag(TimeFrame.month)
			}
			.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
			
			// non-swipeable bottom half of tabs
			switch selectedTimeFrame {
			case .today:
				todayViewList
			case .week:
				weeklyViewList
			case .month:
				monthlyViewList
			}
		}
	}
	
	private var motivationText: some View {
		Text(activityManager.triggerMotivation())
			.font(.headline)
			.foregroundColor(.blue)
			.padding()
			.background(
				RoundedRectangle(cornerRadius: 15)
					.fill(Color.blue.opacity(0.1))
			)
	}
	
	private var todayView: some View {
		VStack {
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
			.frame(maxHeight: 210)
		}
	}
	
	private var todayViewList: some View {
		Group {
			if !activityManager.activities.isEmpty {
				List {
					ForEach(activityManager.activities.filter {
						Calendar.current.isDateInToday($0.date)
					}) { activity in
						ActivityCardView(activity: activity)
					}
				}
				 .listStyle(PlainListStyle())
			} else {
				List {
					Text("No activities logged today")
						.foregroundColor(.gray)
						.padding()
				}
				 .listStyle(PlainListStyle())
			}
		}
		.padding(.top, 20)
	}
	
	private var weeklyView: some View {
		VStack(spacing: 20) {
			ActivityChartView(
				isWeekly: true
			)
		}
		.padding(.top, 20)
	}
	
	private var weeklyViewList: some View {
		Group {
			if !activityManager.activities.isEmpty {
				ActivityBreakdownView(activities: activityManager.getWeeklySummary())
			} else {
				List {
					Text("No activities logged this week.")
						.foregroundColor(.gray)
						.padding()
				}
				.listStyle(PlainListStyle())
			}
		}
		.padding(.top, 20)
	}
	
	private var monthlyView: some View {
		VStack(spacing: 20) {
			ActivityChartView(
				isWeekly: false
			)
		}
		.padding(.top, 20)
	}
	
	private var monthlyViewList: some View {
		Group {
			if !activityManager.activities.isEmpty {
				ActivityBreakdownView(activities: activityManager.getMonthlyActivities())
			} else {
				List {
					Text("No activities logged this month.")
						.foregroundColor(.gray)
						.padding()
				}
				.listStyle(PlainListStyle())
			}
		}
		.padding(.top, 20)
	}
}

#Preview {
	let mockActivityManager = ActivityManager()
	let sampleActivities: [Activity] = [
		Activity(
			date: Date(),
			steps: 8000,
			activeMinutes: 45,
			activityType: "Running"
		),
		Activity(
			date: Date(),
			steps: 5000,
			activeMinutes: 35,
			activityType: "Walking"
		)
	]
	mockActivityManager.activities = sampleActivities
	
	return ActivityTimeFrameView(
		activityManager: mockActivityManager
	)
}
