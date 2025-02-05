//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

@testable import Stanford360
import XCTest

// Separate XCTestCase classes into individual files if required by your linter.
class MealTests: XCTestCase {
    func testMealInitialization() {
        let meal = Meal(name: "Chicken", proteinGrams: 30.0)

        XCTAssertEqual(meal.name, "Chicken")
        XCTAssertEqual(meal.proteinGrams, 30.0)
    }

    func testMealWithOptionalProperties() {
        let imageURL = "test.jpg"
        let meal = Meal(name: "Fish", proteinGrams: 25.0, imageURL: imageURL)

        XCTAssertEqual(meal.imageURL, imageURL)
    }
}

class ProteinIntakeModelTests: XCTestCase {
    private var model: ProteinIntakeModel! // Use private to encapsulate

    override func setUpWithError() throws { // Use setUpWithError for better error handling
        try super.setUpWithError()
        model = ProteinIntakeModel(userID: "testUser", date: Date(), meals: [])
    }

    override func tearDownWithError() throws { // Ensure cleanup is done
        model = nil
        try super.tearDownWithError()
    }

    func testAddMeal() {
        model.addMeal(name: "Test Meal", proteinGrams: 20.0)

        XCTAssertEqual(model.meals.count, 1)
        XCTAssertEqual(model.meals.first?.name, "Test Meal")
        XCTAssertEqual(model.meals.first?.proteinGrams, 20.0)
    }

    func testDeleteMeal() {
        model.addMeal(name: "Meal 1", proteinGrams: 20.0)
        model.addMeal(name: "Meal 2", proteinGrams: 30.0)

        model.deleteMeal(byName: "Meal 1")

        XCTAssertEqual(model.meals.count, 1)
        XCTAssertEqual(model.meals.first?.name, "Meal 2")
    }

    func testTotalProteinCalculation() {
        model.addMeal(name: "Meal 1", proteinGrams: 20.0)
        model.addMeal(name: "Meal 2", proteinGrams: 30.0)

        XCTAssertEqual(model.totalProteinGrams, 50.0)
    }

    func testUpdateMeal() {
        model.addMeal(name: "Original", proteinGrams: 20.0)
        model.updateMeal(oldName: "Original", newName: "Updated", newProteinGrams: 25.0)

        XCTAssertEqual(model.meals.first?.name, "Updated")
        XCTAssertEqual(model.meals.first?.proteinGrams, 25.0)
    }
}
