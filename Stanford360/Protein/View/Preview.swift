//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

#if DEBUG
#Preview {
    @Previewable @State var sampleMeals = [
        Meal(name: "Chicken Breast", proteinGrams: 30.0, imageURL: nil, timestamp: Date()),
        Meal(name: "Protein Shake", proteinGrams: 25.0, imageURL: nil, timestamp: Date()),
        Meal(name: "Egg Whites", proteinGrams: 20.0, imageURL: nil, timestamp: Date())
    ]

    var sampleProteinData = ProteinIntakeModel(
        userID: "sampleUser",
        date: Date(),
        meals: sampleMeals
    )

    return ProteinContentView(proteinData: sampleProteinData)
}
#endif
