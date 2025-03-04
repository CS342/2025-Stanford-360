//
//  ActivityChartView.swift
//  Stanford360
//
//  Created by Elsa Bismuth on 13/02/2025.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT

import Charts
import SwiftUI

struct ActivityChartView: View {
    let activities: [Activity]
    let title: String
    let isWeekly: Bool
    
    // Add colors for different activities
    private let activityColors: [String: Color] = [
        "Walking 🚶‍♂️": .blue,
        "Running 🏃‍♂️": .green,
        "Swimming 🏊‍♂️": .cyan,
        "Dancing 💃": .purple,
        "Basketball 🏀": .orange,
        "Soccer ⚽️": .red,
        "Cycling 🚲": .yellow,
        "School Physical Education 🏟️": .pink,
        "Other 🌟": .gray,
        "HealthKit": .blue
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)
            
            Chart {
                ForEach(activities) { activity in
                    if isWeekly {
                        BarMark(
                            x: .value("Date", activity.date, unit: .day),
                            y: .value("Minutes", activity.activeMinutes)
                        )
                        .foregroundStyle(activityColors[activity.activityType] ?? .blue)
                    } else {
                        LineMark(
                            x: .value("Date", activity.date, unit: .day),
                            y: .value("Minutes", activity.activeMinutes)
                        )
                        .foregroundStyle(activityColors[activity.activityType] ?? .blue)
                        .symbol {
                            Circle()
                                .fill(activityColors[activity.activityType] ?? .blue)
                                .frame(width: 8, height: 8)
                        }
                    }
                }
                
                goalLine()
            }
            .frame(height: 200)
            .padding()
        }
    }
}

#Preview {
    // Sample activities for the last week
    let sampleActivities: [Activity] = [
        Activity(
            date: Date(),
            steps: 8000,
            activeMinutes: 45,
            activityType: "Running"
        ),
        {
            guard let date = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else {
                fatalError("Failed to generate date")
            }
            return Activity(
                date: date,
                steps: 6000,
                activeMinutes: 30,
                activityType: "Walking"
            )
        }()
    ]

    return VStack {
        // Preview weekly chart
        ActivityChartView(
            activities: sampleActivities,
            title: "Weekly Progress",
            isWeekly: true
        )
        
        // Preview monthly chart
        ActivityChartView(
            activities: sampleActivities,
            title: "Monthly Progress",
            isWeekly: false
        )
    }
}
