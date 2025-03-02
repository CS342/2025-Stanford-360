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
    
    // Fetch meals by day
    func fetchMealsByDay() async -> [Meal] {
        var meals: [Meal] = []
        do {
            let today = Date()
            let docRef = try await configuration.userDocumentReference
            let mealsSnapshot = try await docRef.collection("meals").getDocuments()
            meals = try mealsSnapshot.documents.compactMap { doc in
                let meal = try doc.data(as: Meal.self)
                if Calendar.current.isDate(meal.timestamp, inSameDayAs: today) {
                    return meal
                }
                return nil
            }
        } catch {
            print("Error fetching meals by day: \(error)")
        }
        return meals
    }
    
    // Fetch meals by week
//    func fetchMealsByWeek() async -> [Meal] {
//        var meals: [Meal] = []
//        do {
//            let today = Date()
//            let calendar = Calendar.current
//            let docRef = try await configuration.userDocumentReference
//            let mealsSnapshot = try await docRef.collection("meals").getDocuments()
//            meals = try mealsSnapshot.documents.compactMap { doc in
//                let meal = try doc.data(as: Meal.self)
//                if calendar.isDate(meal.timestamp, equalTo: today, toGranularity: .weekOfYear) {
//                    return meal
//                }
//                return nil
//            }
//        } catch {
//            print("Error fetching meals by week: \(error)")
//        }
//        return meals
//    }
//    
//    // Fetch meals by month
//    func fetchMealsByMonth() async -> [Meal] {
//        var meals: [Meal] = []
//        do {
//            let today = Date()
//            let calendar = Calendar.current
//            let docRef = try await configuration.userDocumentReference
//            let mealsSnapshot = try await docRef.collection("meals").getDocuments()
//            meals = try mealsSnapshot.documents.compactMap { doc in
//                let meal = try doc.data(as: Meal.self)
//                if calendar.isDate(meal.timestamp, equalTo: today, toGranularity: .month) {
//                    return meal
//                }
//                return nil
//            }
//        } catch {
//            print("Error fetching meals by month: \(error)")
//        }
//        return meals
//    }
    
    // Delete a meal from Firebase
//    func deleteMeal(id: String?) async throws {
//        if FeatureFlags.disableFirebase {
//            logger.debug("Deleting meal locally")
//            return
//        }
//        do {
//            let snapshot = try await configuration.userDocumentReference
//                .collection("meals")
//                .whereField("id", isEqualTo: id ?? 0)
//                .getDocuments()
//
//            for document in snapshot.documents {
//                try await document.reference.delete()
//            }
//            logger.debug("Meal deleted successfully")
//        } catch {
//            logger.error("Could not delete meal:\(error)")
//            throw error
//        }
//    }
}
