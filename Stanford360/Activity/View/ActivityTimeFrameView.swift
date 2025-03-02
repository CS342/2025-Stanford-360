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
            
            // TabView for swiping
            TabView(selection: $selectedTimeFrame) {
                todayView
                    .tag(TimeFrame.today)
                weeklyView
                    .tag(TimeFrame.week)
                monthlyView
                    .tag(TimeFrame.month)
            }
            .tabViewStyle(PageTabViewStyle())
        }
    }
    
    // Extracted motivation text
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
            DailyProgressView(activeMinutes: activityManager.getTodayTotalMinutes())
                .frame(height: 200)
                .padding()
            
            if !activityManager.activities.isEmpty {
                Text("Today's Activities")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
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
    }
    
    private var weeklyView: some View {
        VStack(spacing: 20) {
            ActivityChartView(
                activities: activityManager.getWeeklySummary(),
                title: "Weekly Progress",
                isWeekly: true
            )
            if !activityManager.activities.isEmpty {
                ActivityBreakdownView(activities: activityManager.getWeeklySummary())
                    .padding(.top, 20)
            } else {
                List {
                    Text("No activities logged this week.")
                        .foregroundColor(.gray)
                        .padding()
                }
                .listStyle(PlainListStyle())
            }
        }
    }
    
    private var monthlyView: some View {
        VStack(spacing: 20) {
            ActivityChartView(
                activities: activityManager.getMonthlyActivities(),
                title: "Monthly Progress",
                isWeekly: false
            )
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
    }
}
#Preview {
    let mockActivityManager = ActivityManager()
    let sampleActivities: [Activity] = [
        Activity(
            date: Date(),
            steps: 8000,
            activeMinutes: 45,
            caloriesBurned: 300,
            activityType: "Running"
        ),
        Activity(
            date: Date(),
            steps: 5000,
            activeMinutes: 35,
            caloriesBurned: 300,
            activityType: "Walking"
        )
    ]
    mockActivityManager.activities = sampleActivities

    return ActivityTimeFrameView(
        activityManager: mockActivityManager
    )
}
