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
    
    var maxProtein: Double {
        meals.map { $0.proteinGrams }.max() ?? 0
    }
    
    // Set chart height to 30% of screen height to prevent overflow
    var chartHeight: CGFloat {
        UIScreen.main.bounds.height * 0.3
    }
    
    var yScaleMax: Double {
        max(maxProtein * 1.2, 200)
    }
    
    var body: some View {
        Chart {
            if meals.isEmpty {
                RuleMark(y: .value("Base", 0))
                    .foregroundStyle(.clear)
                    .annotation(position: .automatic) {
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
        .frame(height: chartHeight)
        .chartYScale(domain: 0...yScaleMax)
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in
                AxisValueLabel()
                    .foregroundStyle(Color.secondary)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisValueLabel()
                AxisGridLine()
            }
        }
        .padding(.vertical)
    }
}
