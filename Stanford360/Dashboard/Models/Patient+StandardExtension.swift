//
//  Standard+PatientExtension.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 2/28/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import Foundation

struct PatientData: @unchecked Sendable {
	let activities: [Activity]
	let hydration: [HydrationLog]
	let meals: [Meal]
}

extension Stanford360Standard {
	/// Returns the patient's activities, hydration, and meals fetched from Firestore
	func fetchPatientData() async throws -> PatientData {
		let docRef = try await configuration.userDocumentReference
		var activities: [Activity] = []
		var hydration: [HydrationLog] = []
		var meals: [Meal] = []
		
		do {
			// fetch collections in parallel
			async let activitiesQuery = docRef.collection("activities").getDocuments()
			async let hydrationQuery = docRef.collection("hydrationLogs").getDocuments()
			async let mealsQuery = docRef.collection("meals").getDocuments()
			
			// wait for all collections to be fetched
			let (activitiesSnapshot, hydrationSnapshot, mealsSnapshot) = try await (activitiesQuery, hydrationQuery, mealsQuery)
			
			// transform firestore documents to models
			activities = try activitiesSnapshot.documents.compactMap { doc in
				try doc.data(as: Activity.self)
			}
			
			hydration = try hydrationSnapshot.documents.compactMap { doc in
				try doc.data(as: HydrationLog.self)
			}
			
			meals = try mealsSnapshot.documents.compactMap { doc in
				try doc.data(as: Meal.self)
			}
		} catch {
			print("Error getting documents: \(error)")
		}
		
		return PatientData(
			activities: activities,
			hydration: hydration,
			meals: meals
		)
	}
}
