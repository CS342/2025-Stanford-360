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
    @State private var totalProtein: Double
    @State private var mealName: String = ""
    @State private var proteinAmount: Double = 0.0
    @State private var showingAddMeal = false

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
            .onAppear {
                updateTotalProtein()
            }
            .navigationTitle("Protein Tracker")
        }
    }

    // MARK: - Initializer
    init(proteinData: ProteinIntakeModel) {
        self.proteinData = proteinData
        _totalProtein = State(initialValue: proteinData.totalProteinGrams)
    }

    // MARK: - Protein Overview
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

    // MARK: - Add Meal Button
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

    // MARK: - Add Meal View
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
                    addMeal(name: mealName, proteinGrams: proteinAmount)
                    mealName = ""
                    proteinAmount = 0.0
                    showingAddMeal = false  // 使用这个来关闭 sheet
                }
            }
            .disabled(mealName.isEmpty || proteinAmount <= 0)
        )
    }

    // MARK: - Meal List
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
    private func addMeal(name: String, proteinGrams: Double) {
        proteinData.addMeal(name: name, proteinGrams: proteinGrams)
        updateTotalProtein()
        // Then store in Firebase
        Task {
            do {
                let meal = Meal(name: name, proteinGrams: proteinGrams)
                try await standard.storeMeal(meal: meal)
            } catch {
                print("Error storing meal to Firebase:\(error)")
                // add UI to deal with exception error catching
            }
        }
    }

    private func deleteMeal(at offsets: IndexSet) {
        for index in offsets {
            let meal = proteinData.meals[index]
            // delete from local model
            proteinData.deleteMeal(byName: meal.name)
            updateTotalProtein()
            
            // delete from firebase
            Task {
                do {
                    try await standard.deleteMeal(withName: meal.name, timestamp: meal.timestamp)
                } catch {
                    print("Error deleting meal from Firebase:\(error)")
                    // add UI to deal with exception error catching
                }
            }
        }
    }

    // loading data when the dataUI first load
    private func updateTotalProtein() {
        totalProtein = proteinData.totalProteinGrams
    }
}
