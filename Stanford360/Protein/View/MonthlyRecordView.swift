//
// WeeklyProteinChartView.swift
//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Charts
import SwiftUI

struct MonthlyRecordView: View {
    struct DailyProteinData: Identifiable {
        let id = UUID()
        let dayName: String
        let proteinGrams: Double
    }
    
    @Environment(ProteinManager.self) private var proteinManager
    var monthlyData: [DailyProteinData] {
        let calendar = Calendar.current
        var monthlyIntake: [String: Double] = [:]

        for meal in proteinManager.meals where calendar.isDate(meal.timestamp, equalTo: Date(), toGranularity: .month) {
            let day = calendar.component(.day, from: meal.timestamp)
            let dayName = String(format: "%02d", day)
            monthlyIntake[dayName, default: 0] += meal.proteinGrams
        }

        return (1...31).map { day in
            let dayName = String(format: "%02d", day)
            return DailyProteinData(dayName: dayName, proteinGrams: monthlyIntake[dayName] ?? 0)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Monthly Protein Intake")
                .font(.headline)
                .foregroundColor(.blue)

            Chart {
                ForEach(monthlyData) { data in
                    LineMark(
                        x: .value("Date", data.dayName),
                        y: .value("Protein", data.proteinGrams)
                    )
                    .interpolationMethod(.monotone)
                    .foregroundStyle(.blue)
                }

                // Goal Line
                RuleMark(y: .value("Goal", 50))
                    .foregroundStyle(.red)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    .annotation(position: .top, alignment: .leading) {
                        Text("Goal")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
            }
            .chartYScale(domain: 0...200)
            .frame(height: 200)
        }
        .padding()
    }
}
