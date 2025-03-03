//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import CoreML
@preconcurrency import Vision
import SwiftUI
import UIKit
import Combine

class ImageClassifier: ObservableObject {
    // MARK: - Published Properties
    @Published var image: UIImage?
    @Published var classificationResults: String = "No results yet"
    @Published var highestConfidenceClassification: String?
    @Published var classificationOptions: [String] = []
    @Published var isProcessing: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Internal Properties
    private let confidenceThreshold: Float = 0.5
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        $image
            .dropFirst()
            .sink { [weak self] newImage in
                if let image = newImage {
                    self?.classifyImage(image)
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Main Classification Method
    func classifyImage(_ image: UIImage) {
        DispatchQueue.main.async {
            self.isProcessing = true
            self.errorMessage = nil
        }
        
        guard let ciImage = CIImage(image: image) else {
            self.handleError("Could not create CIImage from UIImage")
            return
        }

        // 使用方式 1：直接使用 MobileNetV2 类
        guard let model = try? VNCoreMLModel(for: MobileNetV2().model) else {
            self.handleError("Failed to load MobileNetV2 model")
            return
        }

        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let self = self else { return }
            
            if let error = error {
                self.handleError("Classification failed: \(error.localizedDescription)")
                return
            }

            guard let results = request.results as? [VNClassificationObservation] else {
                self.handleError("Could not process classification results")
                return
            }

            let validResults = results.filter { $0.confidence >= self.confidenceThreshold }
            let topResults = validResults.prefix(3)
            
            DispatchQueue.main.async {
                self.classificationOptions = topResults.map {
                    "\($0.identifier) (\(String(format: "%.1f", $0.confidence * 100))%)"
                }
                
                if let highestResult = topResults.first {
                    self.highestConfidenceClassification = highestResult.identifier
                    self.classificationResults = """
                        Top Match: \(highestResult.identifier)
                        Confidence: \(Int(highestResult.confidence * 100))%
                        """
                } else {
                    self.classificationResults = "No confident matches found"
                }
                
                self.isProcessing = false
            }
        }

        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                self.handleError("Failed to perform classification: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Helper Methods
    private func handleError(_ message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
            self.classificationResults = "Error occurred"
            self.isProcessing = false
        }
    }
    
    func reset() {
        DispatchQueue.main.async {
            self.image = nil
            self.classificationResults = "No results yet"
            self.highestConfidenceClassification = nil
            self.classificationOptions = []
            self.errorMessage = nil
            self.isProcessing = false
        }
    }
}
