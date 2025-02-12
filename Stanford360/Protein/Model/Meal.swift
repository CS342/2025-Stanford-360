//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Combine
import Foundation

class Meal: ObservableObject, Identifiable {// for each
    let id = UUID() // Unique identifier for each meal, useful for lists
    @Published var name: String // Name of the meal, e.g., "Chicken breast" or "Protein shake"
    @Published var proteinGrams: Double // Amount of protein in the meal (in grams)
    @Published var imageURL: String? // Optional URL of the meal's image
    @Published var timestamp: Date // Time when the meal was consumed

    // Initializer
    init(name: String, proteinGrams: Double, imageURL: String? = nil, timestamp: Date = Date()) {
        self.name = name
        self.proteinGrams = proteinGrams
        self.imageURL = imageURL
        self.timestamp = timestamp
    }
}
