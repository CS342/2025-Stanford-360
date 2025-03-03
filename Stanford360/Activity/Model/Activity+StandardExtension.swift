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
	// /// Stores an activity document under the current user's subcollection "activities".
	// @MainActor
	// func store(activity: Activity) async throws {
	//     if !FeatureFlags.disableFirebase {
	//         // Get the user's document reference from your Firebase configuration.
	//         let userDocRef = try await configuration.userDocumentReference
	
	//         // Create or access the "activities" subcollection under the user's document.
	//         try userDocRef.collection("activities").addDocument(from: activity)
	
	//         // Optional: Log success
	//         await logger.debug("Activity stored successfully for user \(userDocRef.documentID)")
	//     }
	// }
	
	/// Get activity document reference for a specific date and activity ID
	private func activityDocument(activityId: String = UUID().uuidString) async throws -> DocumentReference {
		let docRef = try await configuration.userDocumentReference
		return docRef
			.collection("activities")
			.document(activityId)
	}
	
	func addActivityToFirestore(activity: Activity) async {
		do {
			let activityData: [String: Any] = [
				"steps": activity.steps,
				"activeMinutes": activity.activeMinutes,
				"caloriesBurned": activity.caloriesBurned,
				"activityType": activity.activityType,
				"date": Timestamp(date: activity.date)
			]
			
			let activityDocRef = try await activityDocument(activityId: activity.id ?? UUID().uuidString)
			try await activityDocRef.setData(activityData, merge: true)
			
			logger.debug("Activity stored successfully")
			await ActivityScheduler().userLoggedActivity()
		} catch {
			logger.error("Could not store activity: \(error)")
		}
	}
	
	func fetchActivities() async -> [Activity] {
		var activities: [Activity] = []
		
		do {
			let docRef = try await configuration.userDocumentReference
			let activitiesSnapshot = try await docRef.collection("activities").getDocuments()
			
			activities = try activitiesSnapshot.documents.compactMap { doc in
				try doc.data(as: Activity.self)
			}
		} catch {
			print("Error fetching activities from Firestore: \(error)")
		}
		
		return activities
	}
	
	//    func fetchActivitiesInRange(from startDate: Date, to endDate: Date) async throws -> [Activity] {
	//        do {
	//            let calendar = Calendar.current
	//            guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: endDate) else {
	//                return []
	//            }
	//            
	//            let activityDocRef = try await activityDocument(date: startDate)
	//            print("✅ Fetching activities from \(startDate) to \(endDate)")
	//            
	//            let snapshot = try await activityDocRef
	//                .collection("dailyActivities")
	//                .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startDate))
	//                .whereField("date", isLessThanOrEqualTo: Timestamp(date: endOfDay))
	//                .getDocuments()
	//            
	//            let activities = snapshot.documents.compactMap { document -> Activity? in
	//                let data = document.data()
	//                // Extract each field safely
	//                let date = (data["date"] as? Timestamp)?.dateValue() ?? startDate
	//                let steps = data["steps"] as? Int ?? 0
	//                let activeMinutes = data["activeMinutes"] as? Int ?? 0
	//                let caloriesBurned = data["caloriesBurned"] as? Int ?? 0
	//                let activityType = data["activityType"] as? String ?? "Unknown"
	//                
	//                return Activity(
	//                    date: date,
	//                    steps: steps,
	//                    activeMinutes: activeMinutes,
	//                    caloriesBurned: caloriesBurned,
	//                    activityType: activityType,
	//                    id: document.documentID
	//                )
	//            }
	//            
	//            print("✅ Found \(activities.count) activities")
	//            return activities.sorted { $0.date > $1.date }
	//        } catch {
	//            print("❌ Error fetching activities: \(error)")
	//            throw error
	//        }
	//    }
}
