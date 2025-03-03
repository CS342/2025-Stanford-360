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
    @Environment(Stanford360Standard.self) private var standard
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
            if let image = selectedImage {
                selectedImageView(image: image)
            } else {
                defaultImageView()
            }
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
    
    
    private var formFields: some View {
        VStack(spacing: 24) {
            inputField(title: "Meal Name", text: $mealName)
            inputField(title: "Protein Amount (g)", text: $proteinAmount, keyboardType: .decimalPad)
        }
        .padding()
    }
    
    
    private var saveButton: some View {
        Button(action: {
            Task {
                await saveMeal()
            }
        }) {
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
    
    private func selectedImageView(image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(height: 400)
            .clipped()
            .accessibilityLabel("selected_image")
            .overlay(editButton())
    }

    private func defaultImageView() -> some View {
        Image("fork.knife.circle.fill")
            .resizable()
            .scaledToFill()
            .frame(height: 400)
            .clipped()
            .accessibilityLabel("fork_background")
            .overlay(defaultOverlayContent())
    }

    private func defaultOverlayContent() -> some View {
        VStack(spacing: 10) {
            Text("Please upload your meal, you are doing great!🎉🎉🎉")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.black.opacity(0.6)))
            addImageButton()
        }
    }

    private func addImageButton() -> some View {
        Button(action: { showSourceSelection = true }) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue)
                .background(Circle().fill(Color.white))
                .shadow(radius: 5)
        }
    }

    private func editButton() -> some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: { showSourceSelection = true }) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                        .background(Circle().fill(Color.white))
                        .shadow(radius: 5)
                }
                .padding()
            }
        }
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
    
    // store image in the meals
//    private func saveMeal() async {
//        isLoading = true
//        let meal = Meal(name: mealName, proteinGrams: Double(proteinAmount) ?? 0)
//        proteinManager.addMeal(name: mealName, proteinGrams: Double(proteinAmount) ?? 0)
//        await standard.storeMeal(meal)
//        await MainActor.run {
//            isLoading = false
//            dismiss()
//        }
//    }
//    private func saveMeal() async {
//        isLoading = true
//        let meal = Meal(name: mealName, proteinGrams: Double(proteinAmount) ?? 0)
//
//        await standard.storeMeal(meal, selectedImage: selectedImage)
//
//        await MainActor.run {
//            proteinManager.addMeal(
//                name: mealName,
//                proteinGrams: Double(proteinAmount) ?? 0,
//                imageURL: meal.imageURL
//            )
//            isLoading = false
//            dismiss()
//        }
//    }
    private func saveMeal() async {
        isLoading = true
        defer { isLoading = false }
        var meal = Meal(name: mealName, proteinGrams: Double(proteinAmount) ?? 0)
        
        // If an image is selected, upload it first
        if let image = selectedImage {
            if let imageURL = await standard.uploadImageToFirebase(image, imageName: meal.id ?? UUID().uuidString) {
                meal.imageURL = imageURL
                print("✅ Image URL uploaded: \(imageURL)")
            } else {
                print("❌ Failed to upload image. Aborting meal save.")
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
