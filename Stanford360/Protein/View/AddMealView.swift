//
//  AddMealView.swift
//  Stanford360
//
//  Created by Jiayu Chang on 3/2/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Combine
import CoreML
import SpeziLLM
import SpeziLLMLocal
import SwiftUI
import UIKit
@preconcurrency import Vision

struct AddMealView: View {
    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss
    @Environment(Stanford360Standard.self) private var standard
    @Environment(ProteinManager.self) private var proteinManager
    @Environment(LLMRunner.self) var runner
    
    // LLM runner state for protein
    // Original state variables
    @State private var mealName: String = ""
    @State private var proteinAmount: String = ""
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var isLoading = false
    @State private var showSourceSelection = false
    // Dynamically adjusts bottom padding to avoid keyboard overlap
    @State private var keyboardOffset: CGFloat = 0
    // SpeziLLM
    // Image classification state
    @State private var classificationResults: String = "No results yet"
    @State private var highestConfidenceClassification: String?
    @State private var classificationOptions: [String] = []
    @State private var isProcessing: Bool = false
    @State private var errorMessage: String?
    @StateObject private var promptTemplate = ProteinPromptConstructor()
    @StateObject private var classifier = ImageClassifier()
    
    
//    var body: some View {
//        NavigationView {
//            ZStack {
//                Color(UIColor.systemGroupedBackground).ignoresSafeArea()
//                mainContent
//            }
//            .toolbar { ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } } }
//            .overlay { if isLoading { loadingView } }
//            .sheet(isPresented: $showingImagePicker) { imagePicker }
//            .confirmationDialog("Choose Image Source", isPresented: $showSourceSelection, titleVisibility: .visible) {
//                sourceSelectionButtons
//            }
//            .onChange(of: selectedImage) { _, newImage in
//                classifier.image = newImage
//                // classifier.classifyImage(newImage)
////                if let image = newImage {
////                    classification(image: image)
////                } else {
////                    print("No image selected")
////                }
//            }
////            .onChange(of: highestConfidenceClassification) { _, newValue in
////                if let classification = newValue, !classification.isEmpty {
////                    // upate mealName according to the result，allow user to edit it
////                    mealName = formatClassificationName(classification)
////                }
////            }
//            
//        }
//    }
    var body: some View {
        NavigationView {
            // Use a ScrollView to make the content scrollable
            ScrollView {
                ZStack {
                    // Background color that ignores safe area
                    Color(UIColor.systemGroupedBackground)
                        .ignoresSafeArea()
                    
                    // Main content with padding around the edges
                    mainContent
                        .padding()
                }
            }
            // Add bottom padding based on the current keyboard height
            .padding(.bottom, keyboardOffset)
            
            // Navigation bar items
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .overlay { if isLoading { loadingView } }
            .sheet(isPresented: $showingImagePicker) { imagePicker }
            .confirmationDialog("Choose Image Source", isPresented: $showSourceSelection, titleVisibility: .visible) {
                sourceSelectionButtons
            }
            
            // Update the classifier when a new image is selected
            .onChange(of: selectedImage) { _, newImage in
                classifier.image = newImage
            }
            .onChange(of: mealName) { newMealName in
                handleMealNameChange(newMealName)
            }
            // Listen for keyboard height changes to avoid overlap
            .onReceive(Publishers.keyboardHeight) { height in
                withAnimation {
                    keyboardOffset = height
                }
            }
        }
    }
    
    func handleMealNameChange(_ newMealName: String) {
        if !newMealName.isEmpty {
            Task {
                await getMealProtein(meal: newMealName)
            }
        } else {
            proteinAmount = ""
        }
    }
}

// MARK: - Main Content
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
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.black.opacity(0.6))
                        )
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

// MARK: - Classification Results
extension AddMealView {
    // MARK: - Classification Results Entry Point
    var classificationResultsView: some View {
        Group {
            if classifier.isProcessing {
                analyzingView
            } else if let errorMsg = classifier.errorMessage {
                errorView(errorMsg)
            } else if !classifier.classificationOptions.isEmpty {
                classificationButtonsView
            }
        }
    }
    
    // MARK: - Subview: Analyzing Indicator
    private var analyzingView: some View {
        Text("Analyzing meals...")
            .font(.subheadline)
            .foregroundColor(.secondary)
            .padding(.top)
    }
    
    
    // MARK: - Subview: Classification Buttons
    private var classificationButtonsView: some View {
        VStack(alignment: .leading) {
            Text("Image Analysis Results:")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(classifier.classificationOptions, id: \.self) { option in
                        Button {
                            // Update mealName with the tapped option
                            mealName = formatClassificationName(option)
                        } label: {
                            Text(formatClassificationName(option))
                                .font(.subheadline)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.blue.opacity(0.1))
                                )
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom)
        }
    }
    
    // MARK: - Subview: Error Display
    private func errorView(_ errorMsg: String) -> some View {
        Text(errorMsg)
            .font(.subheadline)
            .foregroundColor(.red)
            .padding(.top)
    }
    
    // MARK: - Utility
    func formatClassificationName(_ classification: String) -> String {
        classification
            .split(separator: ",")
            .first?
            .split(separator: "_")
            .joined(separator: " ")
            .capitalized
        ?? classification
    }
}

// MARK: - Form Fields
extension AddMealView {
    var formFields: some View {
        VStack(spacing: 24) {
            inputField(title: "Meal Name", text: $mealName)
            inputField(title: "Protein Amount (g)", text: $proteinAmount, keyboardType: .decimalPad)
        }
        .padding()
    }
    
    var saveButton: some View {
        Button(action: {
            Task {
                await saveMeal()
                dismiss()
            }
        }) {
            Text("Save Meal")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isValidInput ? Color.blue : Color.gray)
                )
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
    
    /// Checks if both the meal name is non-empty and the protein amount is a valid positive number
    var isValidInput: Bool {
        if let proteinValue = Double(proteinAmount) {
            return !mealName.isEmpty && proteinValue > 0
        }
        return false
    }
    
    func inputField(title: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            TextField("Enter \(title.lowercased())", text: text)
                .keyboardType(keyboardType)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.secondarySystemGroupedBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

extension AddMealView {
    func getMealProtein(meal: String) async {
        await MainActor.run {
            self.proteinAmount = ""
        }
        let prompt = promptTemplate.constructPrompt(mealName: meal)
        let llmSession: LLMLocalSession = runner(
            with: LLMLocalSchema(
                model: .llama3_8B_4bit,
                parameters: .init(
                    systemPrompt: prompt
                )
            )
        )
//        let llmSession: LLMLocalSession = runner(
//            with: LLMLocalSchema(
//                model: .llama3_8B_4bit
//            )
//        )
        do {
            for try await token in try await llmSession.generate() {
                await MainActor.run {
                    self.proteinAmount.append(token)
                }
            }
            print("Protein extracted is ", proteinAmount)
        } catch {
            print("Error generating protein: \(error)")
        }
    }
}


extension AddMealView {
    func saveMeal() async {
        isLoading = true
        defer { isLoading = false }
        var meal = Meal(name: mealName, proteinGrams: Double(proteinAmount) ?? 0)
        let lastRecordedMilestone = proteinManager.getLatestMilestone()
        
//        if let image = selectedImage {
//            if let imageURL = await standard.uploadImageToFirebase(image, imageName: meal.id ?? UUID().uuidString) {
//                meal.imageURL = imageURL
//            } else {
//                return
//            }
//        }
        
		proteinManager.meals.append(meal)
        await standard.storeMeal(meal/*, selectedImage: selectedImage*/)
        proteinManager.milestoneManager.displayMilestoneMessage(
                newTotal: proteinManager.getTodayTotalGrams(),
                lastMilestone: lastRecordedMilestone,
                unit: "grams of protein"
            )
    }
}

// MARK: - Keyboard Height Publisher
extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { notification -> CGFloat? in
                guard let rect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                    return nil
                }
                return rect.height
            }
            .eraseToAnyPublisher()
        
        let willHide = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ -> CGFloat in
                0
            }
            .eraseToAnyPublisher()
        
        // Merge the two publishers into a single stream of CGFloat
        return Publishers.Merge(willShow, willHide)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
