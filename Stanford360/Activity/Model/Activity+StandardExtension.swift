//
//  Activity+StandardExtension.swift
//  Stanford360
//
//  Created by Elsa Bismuth on 28/02/2025.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

@preconcurrency import FirebaseFirestore
@preconcurrency import FirebaseStorage
import Foundation
import HealthKitOnFHIR
import OSLog
@preconcurrency import PDFKit.PDFDocument
import Spezi
import SpeziAccount
import SpeziFirebaseAccount
import SpeziFirestore
import SpeziHealthKit
import SpeziOnboarding
import SpeziQuestionnaire
import SwiftUI

extension Stanford360Standard {
	/// Get activity document reference for a specific activity ID
	private func activityDocument(activityId: String = UUID().uuidString) async throws -> DocumentReference {
		let docRef = try await configuration.userDocumentReference
		return docRef
			.collection("activities")
			.document(activityId)
	}

	/// Adds a new activity to Firestore
	func addActivityToFirestore(_ activity: Activity) async {
		do {
			let activityData: [String: Any] = [
				"steps": activity.steps,
				"activeMinutes": activity.activeMinutes,
				"activityType": activity.activityType,
				"date": Timestamp(date: activity.date)
			]
			
			let activityDocRef = try await activityDocument(activityId: activity.id ?? UUID().uuidString)
			try await activityDocRef.setData(activityData, merge: true)
			
			logger.debug("Activity stored successfully")
//            await scheduler.userLoggedActivity()
		} catch {
			logger.error("Could not store activity: \(error)")
		}
	}

	/// Updates an activity in both Firestore
	func updateActivityFirestore(activity: Activity) async {
		do {
			let activityData: [String: Any] = [
				"steps": activity.steps,
				"activeMinutes": activity.activeMinutes,
				"activityType": activity.activityType,
				"date": Timestamp(date: activity.date)
			]
			
			let activityDocRef = try await activityDocument(activityId: activity.id ?? UUID().uuidString)
			try await activityDocRef.setData(activityData, merge: true)
			
			logger.debug("Activity updated successfully")
		} catch {
			logger.error("Could not update activity: \(error)")
		}
	}

	/// Deletes an activity from both Firestore
	func deleteActivity(_ activity: Activity) async {
		do {
            let activityDocRef = try await activityDocument(activityId: activity.id ?? UUID().uuidString)
			try await activityDocRef.delete()
            
			logger.debug("Activity deleted successfully")
		} catch {
			logger.error("Could not delete activity: \(error)")
		}
	}
}
