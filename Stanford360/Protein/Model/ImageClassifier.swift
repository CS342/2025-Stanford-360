import Combine
import CoreML
import SwiftUI
import UIKit
@preconcurrency import Vision

@MainActor
class ImageClassifier: ObservableObject {
    // MARK: - Published Properties
    @Published var image: UIImage?
    @Published var classificationOptions: [String] = []
    @Published var isProcessing: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Internal Properties
    private let confidenceThreshold: Float = 0.1
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
    
    func createImageClassifier(for modelName: String) async -> VNCoreMLModel? {
        let defaultConfig = MLModelConfiguration()
        if modelName == "SeeFood" {
            guard let imageClassifierWrapper = try? SeeFood(configuration: defaultConfig),
                  let imageClassifierVisionModel = try? VNCoreMLModel(for: imageClassifierWrapper.model) else {
                return nil
            }
            return imageClassifierVisionModel
        } else if modelName == "MobileNetV2" {
            guard let mobileNetWrapper = try? MobileNetV2(configuration: defaultConfig),
                  let mobileNetVisionModel = try? VNCoreMLModel(for: mobileNetWrapper.model) else {
                return nil
            }
            return mobileNetVisionModel
        }
        return nil
    }

    // MARK: - Main Classification Method
    func classifyImage(_ image: UIImage?) {
        DispatchQueue.main.async {
            self.isProcessing = true
            self.errorMessage = nil
        }
        guard let image = image, let cgImage = image.cgImage else {
            self.handleError("Could not create CIImage from UIImage")
            return
        }
        
        let models = ["SeeFood", "MobileNetV2"]
        let dispatchGroup = DispatchGroup()
        var classificationResults = [VNClassificationObservation]()

        for modelName in models {
            dispatchGroup.enter()
            Task {
                if let model = await self.createImageClassifier(for: modelName) {
                    let request = VNCoreMLRequest(model: model) { request, error in
                        if let error = error {
                            print(error)
                        }
                        if let results = request.results as? [VNClassificationObservation] {
                            classificationResults.append(contentsOf: results.filter { $0.confidence >= self.confidenceThreshold })
                        }
                        print("+++++++", classificationResults)
                        dispatchGroup.leave()
                    }
                    request.imageCropAndScaleOption = .centerCrop
                    let handler = VNImageRequestHandler(cgImage: cgImage, orientation: .up)
                    do {
                        try handler.perform([request])
                    } catch {
                        print(error)
                        dispatchGroup.leave()
                    }
                } else {
                    dispatchGroup.leave()
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            let topResults = classificationResults.sorted(by: { $0.confidence > $1.confidence }).prefix(3)
            self.classificationOptions = topResults.map { "\($0.identifier)" }
            self.isProcessing = false
        }
    }

    func handleError(_ message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
            self.isProcessing = false
        }
    }
}
