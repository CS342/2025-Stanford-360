//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
import Charts
import SwiftUI

struct ChartView: View {
    let meals: [Meal]
    
    var body: some View {
        Chart {
            if meals.isEmpty {
                RuleMark(
                    y: .value("Base", 0)
                )
                .foregroundStyle(.clear)
                .annotation(position: .automatic) {//.overlay
                    Text("No meals added yet")
                        .foregroundStyle(.secondary)
                }
            } else {
                ForEach(meals, id: \.name) { meal in
                    BarMark(
                        x: .value("Meal", meal.name),
                        y: .value("Protein", meal.proteinGrams),
                        width: .fixed(45)
                    )
                    .foregroundStyle(by: .value("Meal", meal.name))
                    .cornerRadius(8)
                }
            }
        }
        .frame(height: 200)
        .chartYScale(domain: 0...200)
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisValueLabel()
                    .foregroundStyle(Color.secondary)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisValueLabel()
                AxisGridLine()
            }
        }
        .padding(.vertical)
    }
}
