//
//  MealTests.swift
//  Stanford360Tests
//
//  Created by Kelly Bonilla Guzmán on 2/10/25.
//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

@testable import Stanford360
import XCTest

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
