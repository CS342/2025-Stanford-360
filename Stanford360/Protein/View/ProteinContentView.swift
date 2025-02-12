//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Charts
import SwiftUI

struct ProteinContentView: View {
    // MARK: - Properties
    @Environment(Stanford360Standard.self) private var standard
    @ObservedObject var proteinData: ProteinIntakeModel
    @State private var totalProtein: Double
    @State private var mealName: String = ""
    @State private var proteinAmount: Double = 0.0
    @State private var showingAddMeal = false
    @State private var isLoading = false
    
    // Image handling states
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showPhotoOptions = false
    @State private var photoSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var isProcessingImage = false

    // MARK: - Body View
    var body: some View {
        NavigationStack {
            VStack {
                proteinOverview()
                ChartView(meals: proteinData.meals)
                Spacer()
                addMealButton()
                mealList()
            }
            .padding()
            // add title, modify the style here
            .navigationTitle("Protein Tracker")
            .onAppear {
                updateTotalProtein()
            }
            .task {
                await loadMealsFromFirebase()
            }
            .overlay {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
        }
    }

    // MARK: - Initializer
    init(proteinData: ProteinIntakeModel) {
        self.proteinData = proteinData
        _totalProtein = State(initialValue: proteinData.totalProteinGrams)
    }

    // MARK: - View Components
    
    // Displays the total protein intake overview
    private func proteinOverview() -> some View {
        VStack {
            Text("Total Protein Intake")
                .font(.largeTitle)
                .bold()
                .padding()
            Text("\(totalProtein, specifier: "%.2f") g")
                .font(.largeTitle)
                .foregroundColor(totalProtein >= 100 ? .green : .primary)
        }
    }

    // Button to add a new meal
    private func addMealButton() -> some View {
        Button("Add Meal") {
            showingAddMeal = true
        }
        .padding()
        .buttonStyle(.borderedProminent)
        .sheet(isPresented: $showingAddMeal) {
            NavigationView {
                addMealView()
            }
        }
    }

    // Form view for adding a new meal, and add camera
    private func addMealView() -> some View {
        Form {
            Section(header: Text("Meal Details")){
                TextField("Meal Name", text: $mealName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField(
                    "Protein (g)",
                    value: $proteinAmount,
                    format: .number
                )
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            Section(header: Text("Optional: Add Photo for Auto-Detection")) {
                VStack(alignment: .center, spacing: 12) {
                    if isProcessingImage {
                        ProgressView("Processing image...")
                            .padding()
                    }
                    
                    if let selectedImage = selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    
                    Button(action: {
                        showPhotoOptions = true
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: selectedImage == nil ? "camera.circle.fill" : "arrow.triangle.2.circlepath.camera.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.blue)
                            Text(selectedImage == nil ? "Add Photo for Auto-Detection" : "Change Photo")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                }
            }
        }
        .navigationTitle("Add New Meal")
        .navigationBarItems(
            trailing: Button("Save") {
                if !mealName.isEmpty && proteinAmount > 0 {
                    Task {
                        await saveMeal()
                    }
                }
            }
            .disabled(mealName.isEmpty || proteinAmount <= 0)
        )
        .actionSheet(isPresented: $showPhotoOptions) {
            ActionSheet(
                title: Text("Add Photo"),
                message: Text("Choose a source"),
                buttons: [
                    .default(Text("Take Photo")) {
                        photoSource = .camera
                        showImagePicker = true
                    },
                    .default(Text("Choose from Library")) {
                        photoSource = .photoLibrary
                        showImagePicker = true
                    },
                    .cancel()
                ]
            )
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(
                sourceType: photoSource,
                selectedImage: Binding(
                    get: { selectedImage },
                    set: { newImage in
                        selectedImage = newImage
                        if let image = newImage {
                            //processSelectedImage(image)
                            print("use API to deal with image")
                        }
                    }
                )
            )
        }
    }

    // List view of all meals
    private func mealList() -> some View {
        List {
            ForEach(proteinData.meals, id: \.name) { meal in
                HStack {
                    VStack(alignment: .leading) {
                        Text(meal.name)
                            .font(.headline)
                        Text(meal.timestamp, style: .date)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Text("\(meal.proteinGrams, specifier: "%.2f") g")
                        .foregroundColor(.secondary)
                }
            }
            .onDelete(perform: deleteMeal)
        }
    }

    // MARK: - Methods
    
    /// Save a new meal to both local state and Firebase
    private func saveMeal() async {
        do {
            // First store in Firebase
            let meal = Meal(name: mealName, proteinGrams: proteinAmount)
            try await standard.storeMeal(meal: meal)
            
            // Then update local state
            await MainActor.run {
                proteinData.addMeal(name: mealName, proteinGrams: proteinAmount)
                updateTotalProtein()
                // Reset form and close sheet
                mealName = ""
                proteinAmount = 0.0
                showingAddMeal = false
            }
        } catch {
            print("Error storing meal to Firebase: \(error)")
        }
    }

    // Delete meals at specified indices
    private func deleteMeal(at offsets: IndexSet) {
        for index in offsets {
            let meal = proteinData.meals[index]
            Task {
                do {
                    // First delete from Firebase
                    try await standard.deleteMeal(withName: meal.name, timestamp: meal.timestamp)
                    
                    // Then update local state
                    await MainActor.run {
                        proteinData.deleteMeal(byName: meal.name)
                        updateTotalProtein()
                    }
                } catch {
                    print("Error deleting meal from Firebase: \(error)")
                }
            }
        }
    }

    // Load meals data from Firebase
    private func loadMealsFromFirebase() async {
        isLoading = true
        do {
            let meals = try await standard.fetchMeals()
            
            // Update UI on main thread
            await MainActor.run {
                // Clear existing meals before adding new ones to reduce duplicate data on the UI
                proteinData.meals.removeAll()
                
                // Add fetched meals
                for meal in meals {
                    proteinData.addMeal(
                        name: meal.name,
                        proteinGrams: meal.proteinGrams,
                        imageURL: meal.imageURL,
                        timestamp: meal.timestamp
                    )
                }
                updateTotalProtein()
                isLoading = false
            }
        } catch {
            print("Error loading meals from Firebase: \(error)")
            isLoading = false
        }
    }

    // Update the total protein count
    private func updateTotalProtein() {
        totalProtein = proteinData.totalProteinGrams
    }
    
    // send notifications
    func sendProteinReminder(){
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["proteinReminder"])
        let content = UNMutableNotificationContent()
        content.title = "Congrats!🎉"
        content.body = "You have meet the protein intake."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 4 * 60 * 60, repeats: false)
        
        let request = UNNotificationRequest(identifier: "proteinReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}
