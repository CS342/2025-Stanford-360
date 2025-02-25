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
    @Environment(Stanford360Standard.self) private var standard
    
    @State private var mealName: String = ""
    @State private var proteinAmount: Double = 0.0
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header Image Section
                    imageSelectionView
                    // Form Fields
                    formFields
                    // Save Button
                    saveButton
                }
            }
            .navigationTitle("Add New Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
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
    
    private var imageSelectionView: some View {
        ZStack {
            Group {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .accessibilityLabel("selectImage")
                } else {
                    Rectangle()
                        .fill(Color(UIColor.secondarySystemBackground))
                }
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            
            Button(action: {
                showingImagePicker = true
            }) {
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 60, height: 60)
                        .shadow(color: Color.black.opacity(0.2), radius: 5)
                    
                    Image(systemName: "camera.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.white)
                        .accessibilityLabel("camera")
                }
            }
        }
        .padding()
    }
    
    private var formFields: some View {
        VStack(spacing: 24) {
            // Meal Name Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Meal Name")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                TextField("Enter meal name", text: $mealName)
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
            
            // Protein Amount Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Protein Amount (g)")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                TextField("", value: $proteinAmount, format: .number)
                    .keyboardType(.decimalPad)
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
        .padding()
    }
    
    private var saveButton: some View {
        Button(action: {
            if !mealName.isEmpty && proteinAmount > 0 {
                Task {
                    await saveMeal()
                }
            }
        }) {
            Text("Save Meal")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(!mealName.isEmpty && proteinAmount > 0 ? Color.blue : Color.gray)
                )
                .padding()
        }
        .disabled(mealName.isEmpty || proteinAmount <= 0)
    }
    
    // Save meal function
    private func saveMeal() async {
        isLoading = true
        
        do {
            // Create a new meal
            let meal = Meal(name: mealName, proteinGrams: proteinAmount)
            
            // Save to Firebase, but should be stored within a day
            try await standard.storeMeal(meal: meal)
            
            // Update local state
            await MainActor.run {
                proteinData.addMeal(name: mealName, proteinGrams: proteinAmount)
                isLoading = false
                dismiss()
            }
        } catch {
            print("Error storing meal to Firebase: \(error)")
            isLoading = false
        }
    }
}

#if DEBUG
#Preview {
    AddMealView(proteinData: ProteinIntakeModel(userID: "test", date: Date(), meals: []))
}
#endif
