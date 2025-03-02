//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import Foundation

extension Stanford360Standard {
	func storeMeal(_ meal: Meal) async {
		guard let mealID = meal.id else {
			print("❌ Meal ID is nil.")
			return
		}
		
		do {
			let docRef = try await configuration.userDocumentReference
			try await docRef.collection("meals").document(mealID).setData(from: meal)
		} catch {
			print("Error writing meal to Firestore: \(error)")
		}
	}
	
	func fetchMeals() async -> [Meal] {
		var meals: [Meal] = []
		
		do {
			let docRef = try await configuration.userDocumentReference
			let mealsSnapshot = try await docRef.collection("meals").getDocuments()
			meals = try mealsSnapshot.documents.compactMap { doc in
				try doc.data(as: Meal.self)
			}
		} catch {
			print("Error fetching meal from Firestore: \(error)")
		}
		
		return meals
	}
}
