//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Combine
import Foundation
import SpeziFirebaseStorage
import UIKit
import FirebaseStorage

class MealImageHandler: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var isProcessing = false
    private let storage = Storage.storage()
    
    // Upload image and create a new meal
    func createMealWithImage(name: String, proteinGrams: Double) async throws -> Meal {
        var imageURL: String? = nil
        
        // Upload image if available
        if let image = selectedImage {
            imageURL = try await uploadImage(image)
        }
        
        // Create and return new meal with image URL
        return Meal(
            name: name,
            proteinGrams: proteinGrams,
            imageURL: imageURL
        )
    }
    
    // Upload image to Firebase Storage and return URL
    private func uploadImage(_ image: UIImage) async throws -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.6) else {
            return nil
        }
        
        let imageName = "\(UUID().uuidString).jpg"
        let storageRef = storage.reference().child("meal_images/\(imageName)")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
        let downloadURL = try await storageRef.downloadURL()
        return downloadURL.absoluteString
    }
}
