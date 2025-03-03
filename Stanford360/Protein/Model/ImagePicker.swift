//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

//import SwiftUI
//
//struct ImagePicker: UIViewControllerRepresentable {
//    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
//        var parent: ImagePicker
//        
//        init(_ parent: ImagePicker) {
//            self.parent = parent
//        }
//        
//        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
//            if let uiImage = info[.originalImage] as? UIImage {
//                parent.image = uiImage
//            }
//            parent.dismiss()
//        }
//        
//        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//            parent.dismiss()
//        }
//    }
//    
//    @Binding var image: UIImage?
//    @Environment(\ .dismiss) private var dismiss
//    var sourceType: UIImagePickerController.SourceType // make sourceType editable
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    func makeUIViewController(context: Context) -> UIImagePickerController {
//        let picker = UIImagePickerController()
//        picker.delegate = context.coordinator
//        picker.sourceType = sourceType // keypoint: choose sourceType
//        return picker
//    }
//
//    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
//        // Nothing to do here
//    }
//}

import SwiftUI
import CoreML
@preconcurrency import Vision
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    // Coordinator handles image picker delegate methods and image classification
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker
        private let classifier = ImageClassifier()
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        // Called when user selects an image
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
                // Perform image classification after image selection
                classifyImage(uiImage)
            }
            parent.dismiss()
        }
        
        // Called when user cancels image selection
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
        
        // Core image classification method
        private func classifyImage(_ image: UIImage) {
            // Update processing state
            DispatchQueue.main.async {
                self.parent.isProcessing = true
                self.parent.errorMessage = nil
            }
            
            // Convert UIImage to CIImage for Vision framework
            guard let ciImage = CIImage(image: image) else {
                self.handleError("Could not create CIImage from UIImage")
                return
            }

            // Load MobileNetV2 ML model
            guard let model = try? VNCoreMLModel(for: MobileNetV2().model) else {
                self.handleError("Failed to load MobileNetV2 model")
                return
            }

            // Create and configure Vision request for classification
            let request = VNCoreMLRequest(model: model) { [weak self] request, error in
                guard let self = self else { return }
                
                // Handle any errors during classification
                if let error = error {
                    self.handleError("Classification failed: \(error.localizedDescription)")
                    return
                }

                // Extract classification results
                guard let results = request.results as? [VNClassificationObservation] else {
                    self.handleError("Could not process classification results")
                    return
                }

                // Filter results by confidence threshold and get top 3
                let validResults = results.filter { $0.confidence >= 0.5 }
                let topResults = validResults.prefix(3)
                
                DispatchQueue.main.async {
                    // Update classification options with confidence scores
                    self.parent.classificationOptions = topResults.map {
                        "\($0.identifier) (\(String(format: "%.1f", $0.confidence * 100))%)"
                    }
                    
                    // Update highest confidence result
                    if let highestResult = topResults.first {
                        self.parent.highestConfidenceClassification = highestResult.identifier
                        self.parent.classificationResults = """
                            Top Match: \(highestResult.identifier)
                            Confidence: \(Int(highestResult.confidence * 100))%
                            """
                    } else {
                        self.parent.classificationResults = "No confident matches found"
                    }
                    
                    // Reset processing state
                    self.parent.isProcessing = false
                }
            }

            // Execute classification request on background thread
            let handler = VNImageRequestHandler(ciImage: ciImage)
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try handler.perform([request])
                } catch {
                    // Fix: Use await when calling handleError from outside the actor context
                    Task { @MainActor in
                        await self.handleError("Failed to perform classification: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        // Helper method to handle errors and update UI
        private func handleError(_ message: String) {
            DispatchQueue.main.async {
                self.parent.errorMessage = message
                self.parent.classificationResults = "Error occurred"
                self.parent.isProcessing = false
            }
        }
    }
    
    // View properties
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    var sourceType: UIImagePickerController.SourceType
    
    // Classification related properties
    @Binding var classificationResults: String
    @Binding var highestConfidenceClassification: String?
    @Binding var classificationOptions: [String]
    @Binding var isProcessing: Bool
    @Binding var errorMessage: String?
    
    // Required methods for UIViewControllerRepresentable
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No updates needed for this implementation
    }
}
