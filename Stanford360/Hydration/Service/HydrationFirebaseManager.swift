//
//  HydrationFirebaseManager.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/4/25.
//

import Foundation

extension Stanford360Standard {
	func fetchHydration() async -> [HydrationIntake] {
		var hydration: [HydrationIntake] = []
		
		do {
			let docRef = try await configuration.userDocumentReference
			let hydrationSnapshot = try await docRef.collection("hydration").getDocuments()
			
			hydration = try hydrationSnapshot.documents.compactMap { doc in
				try doc.data(as: HydrationIntake.self)
			}
		} catch {
			print("Error fetching activities from Firestore: \(error)")
		}
		
		return hydration
	}
	
	func storeHydrationIntake(_ hydrationIntake: HydrationIntake) async {
		guard let hydrationIntakeID = hydrationIntake.id else {
			print("❌ Hydration ID is nil.")
			return
		}

		do {
			let docRef = try await configuration.userDocumentReference
			try await docRef.collection("hydration").document(hydrationIntakeID).setData(from: hydrationIntake)
			print("Stored hydration intake to Firestore")
		} catch {
			print("❌ Error writing meal to Firestore: \(error)")
		}
	}
}
