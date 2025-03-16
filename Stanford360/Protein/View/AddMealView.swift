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
    
    var body: some View {
        NavigationView {
            contentContainer
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") { dismiss() }
                    }
                }
                .sheet(isPresented: $showingImagePicker) { imagePicker }
                .confirmationDialog("Choose Image Source", isPresented: $showSourceSelection, titleVisibility: .visible) {
                    sourceSelectionButtons
                }
                .onChange(of: selectedImage) { _, newImage in
                    classifier.image = newImage
                }
                .onChange(of: mealName) { newMealName in
                    handleMealNameChange(newMealName)
                }
                .onReceive(Publishers.keyboardHeight) { height in
                    withAnimation(.easeOut(duration: 0.25)) {
                        keyboardOffset = height > 0 ? height - 30 : 0 // Slight adjustment for a more natural feel
                    }
                }
        }
    }

    // MARK: - Main Content Container
    private var contentContainer: some View {
        ZStack {
            // Background color covers the entire screen
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            // Use ScrollView to contain content
            ScrollView {
                VStack {
                    imageView
                    classificationResultsView
                    formFields
                    saveButton
                    // Add bottom space to ensure keyboard doesn't overlap content
                    Spacer().frame(height: keyboardOffset)
                }
                .padding(16)
            }
            
            // Ensure loading view covers the entire screen
            if isLoading {
                loadingView
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
    var imageView: some View {
        ZStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 400)
                    .clipped()
                    .frame(width: UIScreen.main.bounds.width * 0.9)
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
                    Text("Please upload a picture of your meal, you are doing great!🎉🎉🎉")
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
        .frame(width: UIScreen.main.bounds.width * 0.9)
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
                .frame(width: UIScreen.main.bounds.width * 0.9)
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
        
        let llmSchema = LLMLocalSchema(
            // model: .custom(id: <#T##String#>),
            model: .llama3_2_1B_4bit,
            parameters: .init(
                systemPrompt: prompt
            )
        )
        let llmSession = runner(with: llmSchema)
        var output = ""
        
        do {
            for try await token in try await llmSession.generate() {
                output.append(token)
            }
            await MainActor.run {
                self.proteinAmount = output
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
        
        if let image = selectedImage {
            if let imageURL = await standard.uploadImageToFirebase(image, imageName: meal.id ?? UUID().uuidString) {
                meal.imageURL = imageURL
            } else {
                return
            }
        }
        
		proteinManager.meals.append(meal)
        let updatedStreak = proteinManager.streak
        await standard.storeMeal(meal/*, selectedImage: selectedImage*/)
        proteinManager.milestoneManager.displayMilestoneMessage(
                newTotal: proteinManager.getTodayTotalGrams(),
                lastMilestone: lastRecordedMilestone,
                unit: "grams of protein",
                streak: updatedStreak
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
