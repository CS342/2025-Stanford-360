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
            print("Error fetching meal to Firestore: \(error)")
        }
        return meals
    }
    
    
    //    func fetchPatientData() async throws -> PatientData {
    //        let docRef = try await configuration.userDocumentReference
    //        var activities: [Activity] = []
    //        var hydration: [HydrationLog] = []
    //        var meals: [Meal] = []
    //
    //        do {
    //            // fetch collections in parallel
    //            async let activitiesQuery = docRef.collection("activities").getDocuments()
    //            async let hydrationQuery = docRef.collection("hydrationLogs").getDocuments()
    //            async let mealsQuery = docRef.collection("meals").getDocuments()
    //
    //            // wait for all collections to be fetched
    //            let (activitiesSnapshot, hydrationSnapshot, mealsSnapshot) = try await (activitiesQuery, hydrationQuery, mealsQuery)
    //
    //            // transform firestore documents to models
    //            activities = try activitiesSnapshot.documents.compactMap { doc in
    //                try doc.data(as: Activity.self)
    //            }
    //
    //            hydration = try hydrationSnapshot.documents.compactMap { doc in
    //                try doc.data(as: HydrationLog.self)
    //            }
    //
    //            meals = try mealsSnapshot.documents.compactMap { doc in
    //                try doc.data(as: Meal.self)
    //            }
    //        } catch {
    //            print("Error getting documents: \(error)")
    //        }
    //
    //        return PatientData(
    //            activities: activities,
    //            hydration: hydration,
    //            meals: meals
    //        )
    //    }
}
