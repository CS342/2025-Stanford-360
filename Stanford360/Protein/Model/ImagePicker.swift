//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import CoreML
import SwiftUI
import UIKit
@preconcurrency import Vision

struct ImagePicker: UIViewControllerRepresentable {
    // Coordinator handles image picker delegate methods and image classification
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: ImagePicker
//        @StateObject private var classifier = ImageClassifier()
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        // Called when user selects an image
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
                // Perform image classification after image selection
                // classifier.image = uiImage
            }
            parent.dismiss()
        }
        
        // Called when user cancels image selection
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
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
