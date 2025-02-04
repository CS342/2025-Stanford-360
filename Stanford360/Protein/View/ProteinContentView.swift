//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//


import SwiftUI

struct ProteinContentView: View {
    var userID: String
    var date: Date
    @State private var proteinData: ProteinIntakeModel
    @State private var totalProtein: Double

    var body: some View {
        NavigationStack {
            VStack {
                ProteinOverview(totalProtein: totalProtein)

                ChartView(meals: proteinData.meals)
                    .frame(height: 300)

                Spacer()

                NavigationLink("Add Meal") {
                    ProteinSetup { name, proteinGrams, imageURL in
                        addMeal(name: name, proteinGrams: proteinGrams, imageURL: imageURL)
                    }
                }
                .padding()
                .buttonStyle(.borderedProminent)

                List {
                    ForEach(proteinData.meals, id: \.name) { meal in
                        MealRow(meal: meal)
                    }
                    .onDelete(perform: deleteMeal)
                }
            }
            .padding()
            .onAppear {
                updateTotalProtein()
                _ = filterMealsByDate(date: Date())
            }
            .navigationTitle("Protein Tracker")
        }
    }

    init(proteinData: ProteinIntakeModel, userID: String = "defaultUser", date: Date = Date()) {
        _proteinData = State(initialValue: proteinData)
        _totalProtein = State(initialValue: proteinData.totalProteinGrams)
        self.userID = userID
        self.date = date
    }

    private func addMeal(name: String, proteinGrams: Double, imageURL: String?) {
        proteinData.addMeal(name: name, proteinGrams: proteinGrams, imageURL: imageURL)
        updateTotalProtein()
    }

    private func deleteMeal(at offsets: IndexSet) {
        offsets.forEach { index in
            let mealName = proteinData.meals[index].name
            proteinData.deleteMeal(byName: mealName)
        }
        updateTotalProtein()
    }

    private func updateTotalProtein() {
        totalProtein = proteinData.totalProteinGrams
    }

    private func filterMealsByDate(date: Date) -> [Meal] {
        proteinData.filterMeals(byDate: date)
    }
}
