//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
struct Meal {
    // V0: user update the name of the meal
    var name: String // Name of the meal, e.g., "Chicken breast" or "Protein shake"
    var proteinGrams: Double // Amount of protein in the meal (in grams)
    var imageURL: String? // Optional URL of the meal's image
    var timestamp: Date // Time when the meal was consumed
}
