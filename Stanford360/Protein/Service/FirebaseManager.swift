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
	func storeMeal(_ meal: Meal/*, selectedImage: UIImage?*/) async {
        guard let mealID = meal.id else {
            print("❌ Meal ID is nil.")
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
            let docRef = try await configuration.userDocumentReference
            try await docRef.collection("meals").document(mealID).setData(from: meal)
            print("✅ Meal saved to Firestore with ID: \(mealID)")
        } catch {
            print("❌ Error writing meal to Firestore: \(error)")
        }
    }
    
    func deleteMealByID(byID id: String) async {
        do {
            let userDocRef = try await configuration.userDocumentReference
            try await userDocRef
                .collection("meals")
                .document(id)
                .delete()
            
            print("✅ Successfully deleted meal with ID: \(id) from Firebase and local data.")
        } catch {
            print("❌ Error deleting meal from Firebase: \(error)")
        }
    }
    
    func uploadImageToFirebase(_ image: UIImage, imageName: String) async -> String? {
        // Resize image before uploading
        let resizedImage = resizeImageIfNeeded(image, maxDimension: 1200)
        
        // Compress with appropriate quality
        guard let imageData = resizedImage.jpegData(compressionQuality: 0.7)
        else {
            return nil
        }
        
        let uniqueImageName = "\(UUID().uuidString)_\(imageName)"
        
        do {
            let storageRef = try await configuration.userBucketReference.child("\(uniqueImageName).jpg")
            
            // Set up upload metadata
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            // Determine if we should use chunked upload based on image size
            // Threshold of 1MB for advanced progress tracking
            let useProgressTracking = imageData.count > 1_000_000
            
            if useProgressTracking {
                // Use progress-tracked upload for larger images
                try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                    let uploadTask = storageRef.putData(imageData, metadata: metadata)
                    
                    // Add progress observer
                    uploadTask.observe(.progress) { snapshot in
                        if let progress = snapshot.progress {
                            let percentComplete = Double(progress.completedUnitCount) / Double(progress.totalUnitCount) * 100
                            print("Upload progress: \(percentComplete)%")
                        }
                    }
                    
                    uploadTask.observe(.success) { _ in
                        continuation.resume(returning: ())
                    }
                    
                    uploadTask.observe(.failure) { snapshot in
                        if let error = snapshot.error {
                            continuation.resume(throwing: error)
                        }
                    }
                }
            } else {
                // Use simple upload for smaller images
                try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                    storageRef.putData(imageData, metadata: metadata) { _, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume(returning: ())
                        }
                    }
                }
            }
            let downloadURL = try await storageRef.downloadURL()
            print("✅ Image successfully uploaded to: \(downloadURL)")
            return downloadURL.absoluteString
        } catch {
            print("❌ Error uploading image: \(error)")
            return nil
        }
    }

    // Helper function to resize images
    private func resizeImageIfNeeded(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let originalSize = image.size
        
        // If the image is already smaller than our target size, return the original
        if originalSize.width <= maxDimension && originalSize.height <= maxDimension {
            return image
        }
        
        // Calculate the target size maintaining aspect ratio
        let aspectRatio = originalSize.width / originalSize.height
        let targetSize: CGSize
        
        if originalSize.width > originalSize.height {
            targetSize = CGSize(width: maxDimension, height: maxDimension / aspectRatio)
        } else {
            targetSize = CGSize(width: maxDimension * aspectRatio, height: maxDimension)
        }
        
        // Render the resized image
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        
        return resizedImage
    }
}

extension StorageReference: @unchecked @retroactive Sendable {}
