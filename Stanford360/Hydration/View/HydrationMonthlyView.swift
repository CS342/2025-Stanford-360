//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Charts
import SwiftUI

struct HydrationMonthlyView: View {
    @Environment(HydrationManager.self) private var hydrationManager

    @State private var selectedDate: String?
    @State private var selectedIntake: Double?
    @State private var selectedPosition: CGPoint?

    private var maxMonthlyIntake: Double {
        max(200, monthlyData.map { $0.intakeOz }.max() ?? 0)
    }

    private var monthlyData: [DailyHydrationData] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        guard let monthRange = calendar.range(of: .day, in: .month, for: today) else {
            return []
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"

        var monthlyIntake: [String: Double] = [:]
        for day in monthRange {
            let dayString = String(format: "%02d", day)
            monthlyIntake[dayString] = 0.0
        }

        for log in hydrationManager.hydration {
            let dayString = dateFormatter.string(from: log.timestamp)
            monthlyIntake[dayString, default: 0] += log.hydrationOunces
        }

        return monthRange.map { day in
            let dayString = String(format: "%02d", day)
            return DailyHydrationData(dayName: dayString, intakeOz: monthlyIntake[dayString] ?? 0)
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Monthly Hydration")
                .font(.headline)
                .foregroundColor(.blue)

            Chart {
                ForEach(monthlyData, id: \.id) { data in
                    LineMark(
                        x: .value("Date", data.dayName),
                        y: .value("Intake", data.intakeOz)
                    )
                    .interpolationMethod(.monotone)
                    .foregroundStyle(.blue.gradient)
                }

                goalLine()
            }
            .chartYScale(domain: 0...maxMonthlyIntake)
            .chartXAxis {
                AxisMarks(values: .automatic) { _ in }
            }
            .frame(height: 200)
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
                    data: monthlyData,
                    selectedDate: $selectedDate,
                    selectedIntake: $selectedIntake,
                    selectedPosition: $selectedPosition
                )
            }
        }
        .padding()
    }
}
