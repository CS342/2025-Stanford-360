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
    let timeFrame: ActivityView.TimeFrame
    let activityManager: ActivityManager
    
    var body: some View {
        switch timeFrame {
        case .today:
            todayView
        case .week:
            weeklyView
        case .month:
            monthlyView
        }
    }
    
    private var todayView: some View {
        VStack {
            DailyProgressView(activeMinutes: activityManager.todayTotalMinutes)
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
                    // Show a placeholder when no activities
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
            ActivityBreakdownView(activities: activityManager.getWeeklySummary())
            List {
                // Show a placeholder when no activities
                Text("No activities logged this week.")
                    .foregroundColor(.gray)
                    .padding()
            }
            .listStyle(PlainListStyle())
        }
    }
    
    private var monthlyView: some View {
        VStack(spacing: 20) {
            ActivityChartView(
                activities: activityManager.getMonthlyActivities(),
                title: "Monthly Progress",
                isWeekly: false
            )
            ActivityBreakdownView(activities: activityManager.getMonthlyActivities())
            List {
                // Show a placeholder when no activities
                Text("No activities logged this month.")
                    .foregroundColor(.gray)
                    .padding()
            }
            .listStyle(PlainListStyle())
        }
    }
}

#Preview {
    let mockActivityManager = ActivityManager()
    // Optionally, you could add some mock activities to the manager
    
    return ActivityTimeFrameView(
        timeFrame: .today,  // You can change this to test different time frames
        activityManager: mockActivityManager
    )
}
