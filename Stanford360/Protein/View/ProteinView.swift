//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProteinView: View {
    @Environment(Stanford360Standard.self) private var standard
    @ObservedObject var proteinData: ProteinIntakeModel
    @State private var isCardAnimating = false
    @State private var showingAddMeal = false
    @State private var mealName: String = ""
    @State private var proteinAmount: Double = 0.0
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    headerView()
                    DailyProgressView(currentValue: Int(proteinData.totalProteinGrams), maxValue:60)
                        .frame(height: 300)
                    mealsCardView()
                }
                .padding()
            }
            .navigationBarHidden(true)
            .background(Color(UIColor.systemGroupedBackground))
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
    
    private func headerView() -> some View {
        Text("Protein Tracker")
            .font(.system(size: 34, weight: .bold, design: .rounded))
            .foregroundColor(.primary)
            .padding(.top)
    }
    
    private func mealsHeaderView() -> some View {
        HStack {
            Text("Daily Meals")
                .font(.title2.bold())
            Spacer()
            Button(action: { showingAddMeal = true }) {
                Text("Add Meal")
                    .font(.subheadline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.blue)
                    )
            }
        }
    }
    
    private func mealsList() -> some View {
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
//            .onDelete(perform: deleteMeal)
        }
    }
    
    private func mealsCardView() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            mealsHeaderView()
            mealsList()
                .opacity(isCardAnimating ? 1 : 0)
                .offset(y: isCardAnimating ? 0 : 50)
                .onAppear {
                    withAnimation(.spring(response: 0.8)) {
                        isCardAnimating = true
                    }
                }
        }
        .sheet(isPresented: $showingAddMeal) {
            NavigationView {
                addMealView()
            }
        }
    }
    
    private func mealRowView(meal: Meal) -> some View {
        NavigationLink(destination: MealDetailView(meal: meal)) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(meal.name)
                        .font(.headline)
                    Text("\(meal.proteinGrams, specifier: "%.1f")g")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(meal.timestamp, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.trailing, 8)
            }
        }
        .contentShape(Rectangle())
    }
    
    private func addMealView() -> some View {
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
    
    // Firebase integration functions
    private func saveMeal() async {
        do {
            let meal = Meal(name: mealName, proteinGrams: proteinAmount)
            try await standard.storeMeal(meal: meal)
            
            await MainActor.run {
                proteinData.addMeal(name: mealName, proteinGrams: proteinAmount)
                mealName = ""
                proteinAmount = 0.0
                showingAddMeal = false
            }
        } catch {
            print("Error storing meal to Firebase: \(error)")
        }
    }
    
    private func loadMealsFromFirebase() async {
        isLoading = true
        do {
            let meals = try await standard.fetchMeals()
            await MainActor.run {
                proteinData.meals.removeAll()
                for meal in meals {
                    proteinData.addMeal(
                        name: meal.name,
                        proteinGrams: meal.proteinGrams,
                        imageURL: meal.imageURL,
                        timestamp: meal.timestamp
                    )
                }
                isLoading = false
            }
        } catch {
            print("Error loading meals from Firebase: \(error)")
            isLoading = false
        }
    }
}

#Preview {
    ProteinView(proteinData: ProteinIntakeModel(userID: "test", date: Date(), meals: []))
}
