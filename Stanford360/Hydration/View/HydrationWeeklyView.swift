//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Charts
import SwiftUI

struct HydrationWeeklyView: View {
    @Environment(HydrationManager.self) private var hydrationManager
    /*
    @State private var selectedDate: String?
    @State private var selectedIntake: Double?
    @State private var selectedPosition: CGPoint?
    */

    private var weeklyData: [DailyHydrationData] {
        let calendar = Calendar.current
        let weekdaySymbols = calendar.shortWeekdaySymbols
        var weeklyIntake: [String: Double] = weekdaySymbols.reduce(into: [:]) { $0[$1] = 0 }

        for log in hydrationManager.hydration where calendar.isDate(log.timestamp, equalTo: Date(), toGranularity: .weekOfYear) {
            let weekday = calendar.component(.weekday, from: log.timestamp)
            let dayName = weekdaySymbols[weekday - 1]
            weeklyIntake[dayName, default: 0] += log.hydrationOunces
        }

        return weekdaySymbols.map { dayName in
            DailyHydrationData(dayName: dayName, intakeOz: weeklyIntake[dayName] ?? 0)
        }
    }

    private var maxWeeklyIntake: Double {
        max(100, weeklyData.map { $0.intakeOz }.max() ?? 0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Hydration")
                .font(.headline)
                .foregroundColor(.blue)

            Chart {
                ForEach(weeklyData) { data in
                    BarMark(
                        x: .value("Day", data.dayName),
                        y: .value("Intake", data.intakeOz)
                    )
                    .foregroundStyle(Color.blue.gradient)
                    .opacity(data.intakeOz > 0 ? 1 : 0)
                }
                // Goal Line
                goalLine()
            }
            .chartXAxis {
                AxisMarks(values: weeklyData.map { $0.dayName })
            }
            .chartYScale(domain: 0...maxWeeklyIntake)
            .frame(height: 200)
            /*
            .overlay(
                ChartInteractionHelper.hoverTooltip(
                    selectedDate: selectedDate,
                    selectedIntake: selectedIntake,
                    selectedPosition: selectedPosition
                )
            )
            .chartOverlay { proxy in
                ChartInteractionHelper.chartHoverGesture(
                    proxy: proxy,
                    data: weeklyData,
                    selectedDate: $selectedDate,
                    selectedIntake: $selectedIntake,
                    selectedPosition: $selectedPosition
                )
            }
            */
        }
        .padding()
    }
}
