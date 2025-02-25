//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct AddMealView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var proteinData: ProteinIntakeModel

    @State private var mealName: String = ""
    @State private var proteinAmount: String = ""  // Store as a string to avoid flickering in TextField
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    imageSelectionView
                    formFields
                    saveButton
                }
            }
            .navigationTitle("Add New Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .overlay {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $selectedImage)
            }
        }
    }

    // Image selection view with a camera button
    private var imageSelectionView: some View {
        ZStack {
            Group {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .accessibilityLabel("Selected Image")
                } else {
                    Rectangle()
                        .fill(Color(UIColor.secondarySystemBackground))
                }
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.2), lineWidth: 1))

            Button(action: { showingImagePicker = true }) {
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 60, height: 60)
                        .shadow(color: Color.black.opacity(0.2), radius: 5)

                    Image(systemName: "camera.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .accessibilityLabel("Camera")
                }
            }
        }
        .padding()
    }

    // Form fields for entering meal name and protein amount
    private var formFields: some View {
        VStack(spacing: 24) {
            // Meal Name Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Meal Name")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                TextField("Enter meal name", text: $mealName)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.secondarySystemGroupedBackground)))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
            }

            // Protein Amount Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Protein Amount (g)")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                TextField("Enter protein grams", text: $proteinAmount)
                    .keyboardType(.decimalPad)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.secondarySystemGroupedBackground)))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
            }
        }
        .padding()
    }

    // Save button to store meal information
    private var saveButton: some View {
        Button(action: {
            if let proteinValue = Double(proteinAmount), !mealName.isEmpty, proteinValue > 0 {
                Task {
                    await saveMeal(proteinValue: proteinValue)
                }
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

    // Check if the input fields are valid
    private var isValidInput: Bool {
        if let proteinValue = Double(proteinAmount) {
            return !mealName.isEmpty && proteinValue > 0
        }
        return false
    }

    // Save meal data and update protein intake model
    private func saveMeal(proteinValue: Double) async {
        isLoading = true
        do {
            let meal = Meal(name: mealName, proteinGrams: proteinValue)
            try await proteinData.addMeal(name: mealName, proteinGrams: proteinValue)
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

#if DEBUG
#Preview {
    AddMealView(proteinData: ProteinIntakeModel(userID: "test", date: Date(), meals: []))
}
#endif
