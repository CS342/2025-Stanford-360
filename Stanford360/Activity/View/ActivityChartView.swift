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
    @Environment(ActivityManager.self) private var activityManager
    var isWeekly: Bool
    
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
        VStack {
            if isWeekly {
                weeklyChart
            } else {
                monthlyChart
            }
        }
    }
    
    private var weeklyChart: some View {
        let timeFrame = TimeFrame.week
        let startDateAxis = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? timeFrame.dateRange().start
        
        return Group {
            Chart {
                let weeklyActivities = activityManager.getWeeklySummary()
                ForEach(weeklyActivities) { activity in
                    BarMark(
                        x: .value("Date", activity.date, unit: .day),
                        y: .value("Minutes", activity.activeMinutes)
                    )
                    .foregroundStyle(activityColors[activity.activityType] ?? .blue)
                }
                goalLine()
            }
            .frame(height: 200)
            .padding()
            .chartYScale(domain: 0...150)
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(date, format: .dateTime.weekday().day())
                        }
                    }
                }
            }
            .chartXScale(domain: startDateAxis...Date())
        }
    }
    
    private var monthlyChart: some View {
        let timeFrame = TimeFrame.month
        let startDateAxis = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? timeFrame.dateRange().start

        return Group {
            Chart {
                let monthlyActivities = activityManager.getMonthlyActivities()
                let activitiesByDate = Dictionary(grouping: monthlyActivities) { Calendar.current.startOfDay(for: $0.date) }

                ForEach(activitiesByDate.keys.sorted(), id: \.self) { date in
                    let totalMinutes = activityManager.getTotalActivityMinutes(activitiesByDate[date] ?? [])
                    
                    LineMark(
                        x: .value("Date", date),
                        y: .value("Total Minutes", totalMinutes)
                    )
                    .foregroundStyle(Color.activityColor)
                    .symbol {
                        Circle()
                            .fill(Color.activityColor)
                            .frame(width: 8, height: 8)
                    }
                }
                goalLine()
            }
            .frame(height: 200)
            .padding()
            .chartYScale(domain: 0...150)
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(date, format: .dateTime.month().day())
                        }
                    }
                }
            }
            .chartXScale(domain: startDateAxis...Date())
        }
    }
}

#Preview {
    VStack {
        // Preview weekly chart
        ActivityChartView(
            isWeekly: true
        )
        
        // Preview monthly chart
        ActivityChartView(
            isWeekly: false
        )
    }
}
