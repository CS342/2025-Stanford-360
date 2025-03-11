//
//  ImageClassifierTest.swift
//  Stanford360
//
//  Created by jiayu chang on 3/11/25.
//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Combine
@testable import Stanford360
import UIKit
import XCTest

@MainActor
final class ImageClassifierTests: XCTestCase {
    var classifier = ImageClassifier()
    var cancellables: Set<AnyCancellable> = []
    
    override func setUp() async throws {
        await MainActor.run {
            classifier = ImageClassifier()
        }
    }

    // Test model loading
    func testCreateImageClassifier() async {
        let model = await classifier.createImageClassifier(for: "SeeFood")
        XCTAssertNotNil(model, "SeeFood model should load successfully")

        let model2 = await classifier.createImageClassifier(for: "MobileNetV2")
        XCTAssertNotNil(model2, "MobileNetV2 model should load successfully")

        let modelInvalid = await classifier.createImageClassifier(for: "InvalidModel")
        XCTAssertNil(modelInvalid, "Invalid model name should return nil")
    }
    
    // Test error handling
    func testHandleError() async {
        await classifier.handleError("Test Error")
        
        let expectation = XCTestExpectation(description: "Error message should be set")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            Task { @MainActor in
                XCTAssertEqual(self.classifier.errorMessage, "Test Error", "Error message was not correctly set")
                XCTAssertFalse(self.classifier.isProcessing, "isProcessing should be false after an error occurs")
                expectation.fulfill()
            }
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    // Test image classification with nil image
    func testClassifyImageWithNilImage() async {
        await classifier.classifyImage(nil)
        
        let expectation = XCTestExpectation(description: "Error message should be set for nil image")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            Task { @MainActor in
                XCTAssertNotNil(self.classifier.errorMessage, "An error message should be displayed")
                XCTAssertEqual(self.classifier.errorMessage, "Could not create CIImage from UIImage")
                XCTAssertFalse(self.classifier.isProcessing, "isProcessing should be false after an error occurs")
                expectation.fulfill()
            }
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
    
    // Test that changing the image triggers classification
    func testImageBindingTriggersClassification() async {
        guard let testImage = UIImage(systemName: "star") else {
            fatalError("Expected system image 'star' to be available")
        }
        
        let expectation = XCTestExpectation(description: "Classification should start when image is set")
        
        classifier.$isProcessing
            .dropFirst()
            .sink { isProcessing in
                if isProcessing {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        await MainActor.run {
            classifier.image = testImage
        }
        
        await fulfillment(of: [expectation], timeout: 2.0)
    }
}
