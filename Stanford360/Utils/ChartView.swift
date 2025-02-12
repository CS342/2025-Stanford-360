//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation

struct ChartView: View {
    let meals: [Meal]

    var body: some View {
        Chart {
            ForEach(meals, id: \.name) { meal in
                BarMark(
                    x: .value("Meal", meal.name),
                    y: .value("Protein (g)", meal.proteinGrams)
                )
                .foregroundStyle(by: .value("Meal", meal.name))
            }
        }
        .chartLegend(.visible)
    }
}
