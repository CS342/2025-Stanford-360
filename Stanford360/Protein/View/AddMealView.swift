//
//  DashboardChart.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/2/25.
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

struct AddMealView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Stanford360Standard.self) private var standard
    @Environment(ProteinManager.self) private var proteinManager
    
    // Original state variables
    @State private var mealName: String = ""
    @State private var proteinAmount: String = ""
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var isLoading = false
    @State private var showSourceSelection = false
    
    // Image classification state
    @State private var classificationResults: String = "No results yet"
    @State private var highestConfidenceClassification: String?
    @State private var classificationOptions: [String] = []
    @State private var isProcessing: Bool = false
    @State private var errorMessage: String?
    @StateObject private var classifier = ImageClassifier()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
                mainContent
            }
            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } } }
            .overlay { if isLoading { loadingView } }
            .sheet(isPresented: $showingImagePicker) { imagePicker }
            .confirmationDialog("Choose Image Source", isPresented: $showSourceSelection, titleVisibility: .visible) {
                sourceSelectionButtons
            }
            .onChange(of: selectedImage) { _, newImage in
                // classifier.image = newImage
                if let image = newImage {
                    classification(image: image)
                } else {
                    print("No image selected")
                }
            }
            .onChange(of: highestConfidenceClassification) { _, newValue in
                if let classification = newValue, !classification.isEmpty {
                    // upate mealName according to the result，allow user to edit it
                    mealName = formatClassificationName(classification)
                }
            }
        }
    }
}


extension AddMealView {
    var mainContent: some View {
        VStack(spacing: 0) {
            imageView
            classificationResultsView
            formFields
            saveButton
        }
    }
    
    var imageView: some View {
        ZStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 400)
                    .clipped()
                    .accessibilityLabel("selected_image")
                    .overlay(alignment: .bottomTrailing) {
                        editButton.padding()
                    }
            } else {
                defaultImageView
            }
        }
        .padding()
    }
    
    var defaultImageView: some View {
        Image("fork.knife.circle.fill")
            .resizable()
            .scaledToFill()
            .frame(height: 400)
            .clipped()
            .accessibilityLabel("fork_background")
            .overlay {
                VStack(spacing: 10) {
                    Text("Please upload your meal, you are doing great!🎉🎉🎉")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.6)))
                    addImageButton
                }
            }
    }
    
    var addImageButton: some View {
        Button(action: { showSourceSelection = true }) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue)
                .background(Circle().fill(Color.white))
                .shadow(radius: 5)
                .accessibilityLabel("plus.circle")
        }
    }
    
    var editButton: some View {
        Button(action: { showSourceSelection = true }) {
            Image(systemName: "pencil.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue)
                .background(Circle().fill(Color.white))
                .shadow(radius: 5)
                .accessibilityLabel("pencil")
        }
    }
}


extension AddMealView {
    var classificationResultsView: some View {
        Group {
            if classifier.isProcessing {
                Text("Analyzing meals...").font(.subheadline).foregroundColor(.secondary).padding(.top)
            } else if let errorMsg = classifier.errorMessage {
                Text(errorMsg).font(.subheadline).foregroundColor(.red).padding(.top)
            } else if !classifier.classificationOptions.isEmpty {
                VStack(alignment: .leading) {
                    Text("Image Analysis Results:").font(.headline).padding(.horizontal)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(classifier.classificationOptions, id: \ .self) { option in
                                Text(option)
                                    .font(.subheadline)
                                    .padding(8)
                                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.blue.opacity(0.1)))
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom)
                }
            }
        }
    }
}


extension AddMealView {
    var formFields: some View {
        VStack(spacing: 24) {
            inputField(title: "Meal Name", text: $mealName)
            inputField(title: "Protein Amount (g)", text: $proteinAmount, keyboardType: .decimalPad)
        }
        .padding()
    }
    
    var saveButton: some View {
        Button(action: { Task { await saveMeal() } }) {
            Text("Save Meal")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(isValidInput ? Color.blue : Color.gray))
                .padding()
        }
        .disabled(!isValidInput)
    }
    
    var loadingView: some View {
        ProgressView()
            .scaleEffect(1.5)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.2))
    }
    
    var imagePicker: some View {
        ImagePicker(
            image: $selectedImage,
            sourceType: sourceType,
            classificationResults: $classificationResults,
            highestConfidenceClassification: $highestConfidenceClassification,
            classificationOptions: $classificationOptions,
            isProcessing: $isProcessing,
            errorMessage: $errorMessage
        )
    }
    
    var sourceSelectionButtons: some View {
        Group {
            Button("Choose from Library") {
                sourceType = .photoLibrary
                showingImagePicker = true
            }
            Button("Take a Photo") {
                sourceType = .camera
                showingImagePicker = true
            }
            Button("Cancel", role: .cancel) { }
        }
    }
    
    var isValidInput: Bool {
        if let proteinValue = Double(proteinAmount) {
            return !mealName.isEmpty && proteinValue > 0
        }
        return false
    }
    
    func inputField(title: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline).foregroundStyle(.secondary)
            TextField("Enter \(title.lowercased())", text: text)
                .keyboardType(keyboardType)
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.secondarySystemGroupedBackground)))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
        }
    }
}


extension AddMealView {
    // convert A image to cv Pixel Buffer with 224*224
    func convertImage(image: UIImage) -> CVPixelBuffer? {
        let newSize = CGSize(width: 224.0, height: 224.0)
        UIGraphicsBeginImageContext(newSize)
        image.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        
        UIGraphicsEndImageContext()
        
        let attributes = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
                  kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         Int(newSize.width),
                                         Int(newSize.height),
                                         kCVPixelFormatType_32ARGB,
                                         attributes,
                                         &pixelBuffer)
        
        guard let createdPixelBuffer = pixelBuffer, status == kCVReturnSuccess else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(createdPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(createdPixelBuffer)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: pixelData,
                                      width: Int(newSize.width),
                                      height: Int(newSize.height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: CVPixelBufferGetBytesPerRow(createdPixelBuffer),
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) else {
            return nil
        }
        
        context.translateBy(x: 0, y: newSize.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context)
        resizedImage.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(createdPixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return createdPixelBuffer
    }
}

extension AddMealView {
    func classification(image: UIImage) {
        let mobilenet = MobileNetV2()
        if let imagebuffer = convertImage(image: image) {
            do {
                let prediction = try mobilenet.prediction(image: imagebuffer)
                print(prediction.classLabel)
                highestConfidenceClassification = prediction.classLabel
            } catch {
                print("ERROR prediction ", error)
            }
        }
    }
    
    func processClassificationResults(_ results: [VNClassificationObservation]) {
        let validResults = results.filter { $0.confidence >= 0.5 }
        let topResults = validResults.prefix(3)
        
        classificationOptions = topResults.map {
            "\($0.identifier) (\(String(format: "%.1f", $0.confidence * 100))%)"
        }
        
        if let highestResult = topResults.first {
            highestConfidenceClassification = highestResult.identifier
            classificationResults = "Top Match: \(highestResult.identifier)"
        } else {
            classificationResults = "No confident matches found"
        }
        
        isProcessing = false
    }
    
    func formatClassificationName(_ classification: String) -> String {
        classification
            .split(separator: ",").first?
            .split(separator: "_").joined(separator: " ")
            .capitalized ?? classification
    }
}

extension AddMealView {
    func saveMeal() async {
        isLoading = true
        defer { isLoading = false }
        var meal = Meal(name: mealName, proteinGrams: Double(proteinAmount) ?? 0)
        
        if let image = selectedImage {
            if let imageURL = await standard.uploadImageToFirebase(image, imageName: meal.id ?? UUID().uuidString) {
                meal.imageURL = imageURL
            } else {
                return
            }
        }
        
        await standard.storeMeal(meal, selectedImage: selectedImage)
        await MainActor.run {
            proteinManager.addMeal(
                name: meal.name,
                proteinGrams: meal.proteinGrams,
                imageURL: meal.imageURL
            )
            dismiss()
        }
    }
}
