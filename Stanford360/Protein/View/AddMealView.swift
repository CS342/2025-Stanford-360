//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct AddMealView: View {
    @Environment(\ .dismiss) private var dismiss
    @Environment(ProteinManager.self) private var proteinManager

    @State private var mealName: String = ""
    @State private var proteinAmount: String = ""  // Store as a string to avoid flickering in TextField
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var isLoading = false
    @State private var showSourceSelection = false // Controls the selection sheet

    var body: some View {
        NavigationView {
            ZStack {
                backgroundView
                content
            }
//            .navigationTitle("Add New Meal")
//            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
            .overlay { loadingOverlay }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage, sourceType: sourceType)
            }
            .confirmationDialog("Choose Image Source", isPresented: $showSourceSelection, titleVisibility: .visible) {
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
    }

    private var imageSelectionView: some View {
        ZStack {
            Image("fork.knife.circle.fill") // Add a background image
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .clipped()
                .accessibilityLabel("fork_background")
                .overlay(
                    VStack(spacing: 10) {
                        Text("Please upload your meal, you are doing great!🎉🎉🎉")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.6)))
                        
                        Button(action: { showSourceSelection = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.blue)
                                .background(Circle().fill(Color.white))
                                .shadow(radius: 5)
                        }
                    }
                )
        }
        .padding()
    }

    private var backgroundView: some View {
        Color(UIColor.systemGroupedBackground)
            .ignoresSafeArea()
    }
    
    private var content: some View {
        VStack(spacing: 0) {
            imageSelectionView
            formFields
            saveButton
        }
    }

    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel") { dismiss() }
        }
    }

    private var loadingOverlay: some View {
        Group {
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.2))
            }
        }
    }

//    private var imageSelectionView: some View {
//        ZStack {
//            imagePlaceholder
//            addImageButton
//        }
//        .padding()
//    }

//    private var imagePlaceholder: some View {
//        Group {
//            if let image = selectedImage {
//                Image(uiImage: image)
//                    .resizable()
//                    .scaledToFill()
//                    .accessibilityLabel("Selected Image")
//            } else {
//                Rectangle()
//                    .fill(Color(UIColor.secondarySystemBackground))
//            }
//        }
//        .frame(height: 200)
//        .clipShape(RoundedRectangle(cornerRadius: 16))
//        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.2), lineWidth: 1))
//    }

//    private var addImageButton: some View {
//        Button(action: { showSourceSelection = true }) {
//            Image(systemName: "plus.circle.fill")
//                .font(.system(size: 40))
//                .foregroundColor(.blue)
//                .shadow(radius: 3)
//                .background(Circle().fill(.white))
//                .accessibilityLabel("Add Image Button")
//        }
//        .padding(.top, 80)
//    }

    private var formFields: some View {
        VStack(spacing: 24) {
            inputField(title: "Meal Name", text: $mealName)
            inputField(title: "Protein Amount (g)", text: $proteinAmount, keyboardType: .decimalPad)
        }
        .padding()
    }


    private var saveButton: some View {
        Button(action: { attemptSaveMeal() }) {
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

    private var isValidInput: Bool {
        if let proteinValue = Double(proteinAmount) {
            return !mealName.isEmpty && proteinValue > 0
        }
        return false
    }
    
    private func inputField(title: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
            TextField("Enter \(title.lowercased())", text: text)
                .keyboardType(keyboardType)
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.secondarySystemGroupedBackground)))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
        }
    }

    private func attemptSaveMeal() {
        if let proteinValue = Double(proteinAmount), !mealName.isEmpty, proteinValue > 0 {
            Task { await saveMeal(proteinValue: proteinValue) }
        }
    }

    private func saveMeal(proteinValue: Double) async {
        isLoading = true
        do {
            let meal = Meal(name: mealName, proteinGrams: proteinValue)
            try await proteinManager.addMeal(name: mealName, proteinGrams: proteinValue)
            await MainActor.run {
                isLoading = false
                dismiss()
            }
        } catch {
            print("Error saving meal: \(error)")
            isLoading = false
        }
    }
}
