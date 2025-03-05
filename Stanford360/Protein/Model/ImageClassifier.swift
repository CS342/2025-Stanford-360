//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Combine
import CoreML
import SwiftUI
import UIKit
@preconcurrency import Vision

@MainActor
class ImageClassifier: ObservableObject {
    // MARK: - Published Properties
    @Published var image: UIImage?
    // @Published var classificationResults: String = "No results yet"
    // @Published var highestConfidenceClassification: String?
    @Published var classificationOptions: [String] = []
    @Published var isProcessing: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Internal Properties
    private let confidenceThreshold: Float = 0.7
    private var cancellables = Set<AnyCancellable>()
    private var predictionHandlers = [VNRequest: ImagePredictionHandler]()
    
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
    
    func createImageClassifier() -> VNCoreMLModel {
        // Use a default model configuration.
        let defaultConfig = MLModelConfiguration()
        // Create an instance of the image classifier's wrapper class.
        let imageClassifierWrapper = try? SeeFood(configuration: defaultConfig)

        guard let imageClassifier = imageClassifierWrapper else {
            fatalError("App failed to create an image classifier model instance.")
        }
        // Get the underlying model instance.
        let imageClassifierModel = imageClassifier.model

        // Create a Vision instance using the image classifier's model instance.
        guard let imageClassifierVisionModel = try? VNCoreMLModel(for: imageClassifierModel) else {
            fatalError("App failed to create a `VNCoreMLModel` instance.")
        }
        return imageClassifierVisionModel
    }

    // MARK: - Main Classification Method
    func classifyImage(_ image: UIImage?) {
        DispatchQueue.main.async {
            self.isProcessing = true
            self.errorMessage = nil
        }
        guard let image = image,
              let _ = CIImage(image: image) else {
            self.handleError("Could not create CIImage from UIImage")
            return
        }
        
        let imageClassifier = createImageClassifier()
        
        let imageClassificationRequest = VNCoreMLRequest(
            model: imageClassifier,
            completionHandler: { request, error in
                if let error = error {
                    print(error)
                }
                print(request.results)
            })
        
        imageClassificationRequest.imageCropAndScaleOption = .centerCrop
        
        let handler = VNImageRequestHandler(cgImage: image.cgImage!, orientation: .up)
        let requests: [VNRequest] = [imageClassificationRequest]
        
        do {
            try handler.perform(requests)
        } catch {
            print(error)
        }
    }
    
    typealias ImagePredictionHandler = (_ predictions: [String]?) -> Void
    
    private func visionRequestHandler(_ request: VNRequest, error: Error?) {
        // Remove the caller's handler from the dictionary and keep a reference to it.
        guard let predictionHandler = predictionHandlers.removeValue(forKey: request) else {
            fatalError("Every request must have a prediction handler.")
        }

        // Check for an error first.
        if let error = error {
            print("Vision image classification error...\n\n\(error.localizedDescription)")
            return
        }

        // Check that the results aren't `nil`.
        if request.results == nil {
            print("Vision request had no results.")
            return
        }

        // Cast the request's results as an `VNClassificationObservation` array.
        guard let observations = request.results as? [VNClassificationObservation] else {
            // Image classifiers, like MobileNet, only produce classification observations.
            // However, other Core ML model types can produce other observations.
            // For example, a style transfer model produces `VNPixelBufferObservation` instances.
            print("VNRequest produced the wrong result type: \(type(of: request.results)).")
            return
        }

        // Create a prediction array from the observations.
        observations.forEach { observation in
            // Convert each observation into an `ImagePredictor.Prediction` instance.
            print(observation.identifier, observation.confidence)
        }
    }
    
    func handleError(_ message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
            // self.classificationResults = "Error occurred"
            self.isProcessing = false
        }
    }
}
