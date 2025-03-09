//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import FirebaseStorage
import Foundation

extension Stanford360Standard {
//	func storeMeal(_ meal: Meal) async {
//		guard let mealID = meal.id else {
//			print("❌ Meal ID is nil.")
//			return
//		}
//		
//		do {
//			let docRef = try await configuration.userDocumentReference
//			try await docRef.collection("meals").document(mealID).setData(from: meal)
//		} catch {
//			print("Error writing meal to Firestore: \(error)")
//		}
//	}
	func storeMeal(_ meal: Meal/*, selectedImage: UIImage?*/) async {
        print("storing meal id to firestore")
        print(meal)
        guard let mealID = meal.id else {
            print("Meal ID is nil.")
            return
        }

//        var updatedMeal = meal
//
//        // If an image is selected, upload the image and get its download URL
//        if let image = selectedImage {
//            if let imageURL = await uploadImageToFirebase(image, imageName: meal.name) {
//                updatedMeal.imageURL = imageURL
//                print("✅ Image URL uploaded: \(imageURL)")
//            } else {
//                print("❌ Failed to upload image.")
//            }
//        }

        // store the Meal to Firestore
        do {
            let mealDocRef = try await mealDocument(mealId: meal.id ?? UUID().uuidString)
            try await mealDocRef.setData(from: meal, merge: true)
            print("Meal saved to Firestore with ID: \(mealID)")
        } catch {
            print("Error writing meal to Firestore: \(error)")
        }
    }
    
    // Fetch meals by day
//    func fetchMealsByDay() async -> [Meal] {
//        var meals: [Meal] = []
//        do {
//            let today = Date()
//            let docRef = try await configuration.userDocumentReference
//            let mealsSnapshot = try await docRef.collection("meals").getDocuments()
//            meals = try mealsSnapshot.documents.compactMap { doc in
//                let meal = try doc.data(as: Meal.self)
//                if Calendar.current.isDate(meal.timestamp, inSameDayAs: today) {
//                    return meal
//                }
//                return nil
//            }
//        } catch {
//            print("Error fetching meals by day: \(error)")
//        }
//        return meals
//    }
    
    private func mealDocument(mealId: String = UUID().uuidString) async throws -> DocumentReference {
        let docRef = try await configuration.userDocumentReference
        return docRef
            .collection("meals")
            .document(mealId)
    }
    
    func deleteMeal(_ meal: Meal) async {
        print("trying to delete meal in firestore")
        print(meal)
        do {
            let mealDocRef = try await mealDocument(mealId: meal.id ?? UUID().uuidString)
            print("meal doc ref")
            print(mealDocRef)
            try await mealDocRef.delete()
            print("deleted meal from firestore")
            
            logger.debug("Meal deleted successfully")
        } catch {
            logger.error("Could not delete meal: \(error)")
        }
    }
//    
//    func deleteMealByID(byID id: String) async {
//        do {
//            let userDocRef = try await configuration.userDocumentReference
//            try await userDocRef
//                .collection("meals")
//                .document(id)
//                .delete()
//            
//            print("✅ Successfully deleted meal with ID: \(id) from Firebase and local data.")
//        } catch {
//            print("❌ Error deleting meal from Firebase: \(error)")
//        }
//    }
    
//    func uploadImageToFirebase(_ image: UIImage, imageName: String) async -> String? {
//        guard let imageData = image.jpegData(compressionQuality: 0.8)
//        else {
//            return nil
//        }
//        let uniqueImageName = "\(UUID().uuidString)_\(imageName)"
//        let storageRef = Storage.storage().reference().child("meal_images/\(uniqueImageName).jpg")
//        
//        do {
//            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
//                storageRef.putData(imageData, metadata: nil) { _, error in
//                    if let error = error {
//                        continuation.resume(throwing: error)
//                    } else {
//                        continuation.resume(returning: ())
//                    }
//                }
//            }
//            let downloadURL = try await storageRef.downloadURL()
//            print("✅ Image successfully uploaded to: \(downloadURL)")
//            return downloadURL.absoluteString
//        } catch {
//            print("❌ Error uploading image: \(error)")
//            return nil
//        }
//    }
}
