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

    @Environment(Stanford360Standard.self) private var standard
    @ObservedObject var proteinData: ProteinIntakeModel
    @State private var totalProtein: Double // consider this design
    @State private var mealName: String = ""
    @State private var proteinAmount: Double = 0.0
    @State private var showingAddMeal = false
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            VStack {
                headerView()
                proteinOverview()
                ChartView(meals: proteinData.meals)
                // Spacer()
                addMealButton()
                congratulatoryDisplay()
                mealList()
            }
            .padding()
            //.navigationTitle("Protein Tracker")
            .task {
                updateTotalProtein()
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


    init(proteinData: ProteinIntakeModel) {
        self.proteinData = proteinData
        _totalProtein = State(initialValue: proteinData.totalProteinGrams)
    }
    
    func headerView() -> some View {
        Text("🍗 Protein Tracker")
            .font(.largeTitle)
            .bold()
            .padding()
            // .accessibilityLabel("Protein Tracker Header")
    }

    // Displays the total protein intake overview
    func proteinOverview() -> some View {
        VStack {
            Text("Total Protein Intake")
                .font(.title2)
                .bold()
                .padding()
            Text("\(totalProtein, specifier: "%.2f") g")
                .font(.title2)
                .foregroundColor(totalProtein >= 100 ? .green : .primary)
        }
    }

    // Button to add a new meal
    func addMealButton() -> some View {
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

    // Form view for adding a new meal
    func addMealView() -> some View {
        Form {
            Section {
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
    }

    // List view of all meals
    // List view of all meals
    func mealList() -> some View {
        List {
            // ForEach(proteinData.meals, id: \.id) { meal in -> modify the only one? Is there a need?
            ForEach(proteinData.meals, id: \.name) { meal in
                NavigationLink(destination: MealDetailView(meal: meal)) {
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
            }
            .onDelete(perform: deleteMeal)
        }
    }

    
    // Save a new meal to both local state and Firebase
    func saveMeal() async {
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
                print("Meal have been added to the firebase!")
            }
        } catch {
            print("Error storing meal to Firebase: \(error)")
        }
    }

    // Delete meals at specified indices
    func deleteMeal(at offsets: IndexSet) {
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
    func loadMealsFromFirebase() async {
        isLoading = true
        do {
            let meals = try await standard.fetchMeals()
            
            // Update UI on main thread
            await MainActor.run {
                // Clear existing meals before adding new ones
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
    func updateTotalProtein() {
        totalProtein = proteinData.totalProteinGrams
    }
    
    // trigger congratulatory messages for the first 30-gram of protein consumed and upon reaching the 60-gram protein target
    func congratulatoryDisplay() -> some View {
        Group {
            if totalProtein >= 30 && totalProtein < 60 {
                Text("You have reached the first 30-gram of protein goal. You need \(String(format: "%.1f", 60 - totalProtein)) gram more to reach your goal!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else if totalProtein >= 60 {
                Text("Congratulations! You've reached your protein intake goal! 🎉")
                    .font(.subheadline)
                    .foregroundColor(.green)
            } else {
                Text("Keep going! You're doing great! 💪")
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
        }
    }
}
    
    // send notifications
//    func sendProteinReminder(){
//        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["proteinReminder"])
//        let content = UNMutableNotificationContent()
//        content.title = "Congrats!🎉"
//        content.body = "You have meet the protein intake."
//        content.sound = .default
//        
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 4 * 60 * 60, repeats: false)
//        
//        let request = UNNotificationRequest(identifier: "proteinReminder", content: content, trigger: trigger)
//        
//        UNUserNotificationCenter.current().add(request)
//    }
