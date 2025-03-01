//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import Foundation

struct Meal: Identifiable, Codable {
	@DocumentID var id: String?
	var name: String // Name of the meal, e.g., "Chicken breast" or "Protein shake"
	var proteinGrams: Double // Amount of protein in the meal (in grams)
	var imageURL: String? // Optional URL of the meal's image
	var timestamp: Date // Time when the meal was consumed
	
	init(
		name: String,
		proteinGrams: Double,
		imageURL: String? = nil,
		timestamp: Date = Date(),
		id: String? = UUID().uuidString
	) {
		self.id = id
		self.name = name
		self.proteinGrams = proteinGrams
		self.imageURL = imageURL
		self.timestamp = timestamp
	}
}
