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
	/// Migrates hydration logs from the old model to the new model
	func migrateHydrationLogs() async {
		do {
			let docRef = try await configuration.userDocumentReference
			let hydrationSnapshot = try await docRef.collection("hydrationLogs").getDocuments()
			
			for document in hydrationSnapshot.documents {
				let data = document.data()
				
				// check if document adheres to old model
				if let amountOz = data["amountOz"] as? Double,
				   let lastHydrationDate = (data["lastHydrationDate"] as? Timestamp)?.dateValue() {
					// create and store new document ahdering to new model
					let newLogID = UUID().uuidString
					let newLog = HydrationLog(
						hydrationOunces: amountOz,
						timestamp: lastHydrationDate,
						id: newLogID
					)
					
					try await docRef.collection("hydrationLogs").document(newLogID).setData(from: newLog)
					
					// remove old-model document after successful migration
					 try await document.reference.delete()
					 logger.debug("Deleted old-format hydration log: \(document.documentID)")
				}
			}
			
			logger.debug("Hydration logs migration completed")
		} catch {
			logger.error("Error migrating hydration logs: \(error)")
		}
	}
	
	func processHydrationLogsDuringMigration(hydrationSnapshot: QuerySnapshot) async -> [HydrationLog] {
		var hydration: [HydrationLog] = []
		
		for doc in hydrationSnapshot.documents {
			// attempt to decode with new model
			if let log = try? doc.data(as: HydrationLog.self) {
				hydration.append(log)
				continue
			}
			
			// if decoding fails, convert to new model and save conversion
			let data = doc.data()
			if let amountOz = data["amountOz"] as? Double,
			   let lastHydrationDate = (data["lastHydrationDate"] as? Timestamp)?.dateValue() {
				let convertedLog = HydrationLog(
					hydrationOunces: amountOz,
					timestamp: lastHydrationDate,
					id: doc.documentID
				)
				
				hydration.append(convertedLog)
				logger.debug("Converted old-format hydration log: \(doc.documentID)")
			}
		}
		
		return hydration
	}
	
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
			
			// Process hydration logs with error handling for different formats
			hydration = await processHydrationLogsDuringMigration(hydrationSnapshot: hydrationSnapshot)
			
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
