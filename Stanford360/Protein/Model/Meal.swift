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
    // @Published var weights: Double //weight of food intake, a function is used to calculate the proteinGrams based on API/database
    @Published var imageURL: String? // Optional URL of the meal's image
    @Published var timestamp: Date // Time when the meal was consumed

    // Initializer
    init(name: String, proteinGrams: Double, imageURL: String? = nil, timestamp: Date = Date()) {
        self.name = name
        self.proteinGrams = proteinGrams
        // self.weights = weights
        self.imageURL = imageURL
        self.timestamp = timestamp
    }
    
    // Calculate protein content based on weight
//    func calculateProteinContent() -> Double {
//        // Simple calculation for now (weights / 10)
//        // - API calls to nutrition database
//        // - Different calculation rules for different food types
//        // - Consider protein density per 100g
//        // - Account for cooking methods
//        return weights / 10.0
//    }
    // Update protein content based on weight
//    func updateProteinBasedOnWeight() {
//        proteinGrams = calculateProteinContent()
//    }
//    
//    // Convenience method to update weight and recalculate protein
//    func updateWeight(_ newWeight: Double) {
//        weights = newWeight
//        updateProteinBasedOnWeight()
//    }
}
