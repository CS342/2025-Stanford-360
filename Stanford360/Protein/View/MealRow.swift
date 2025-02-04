//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct MealRow: View {
    let meal: Meal

    var body: some View {
        HStack {
            Text(meal.name)
            Spacer()
            Text("\(meal.proteinGrams, specifier: "%.2f") g")
                .foregroundColor(.secondary)
        }
    }
}
