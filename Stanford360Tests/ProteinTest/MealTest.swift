// periphery:ignore:all
//
//  MealTest.swift
//  Stanford360
//
//  Created by jiayu chang on 3/11/25.
//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

@testable import Stanford360
import XCTest

final class MealTests: XCTestCase {
    // Test Meal Initialization with all properties
    func testMealInitialization() {
        let meal = Meal(
            name: "Chicken Breast",
            proteinGrams: 30.0,
            imageURL: "https://example.com/chicken.jpg",
            timestamp: Date(),
            id: "test-id-123"
        )
        
        XCTAssertEqual(meal.name, "Chicken Breast", "Meal name should match the initialized value.")
        XCTAssertEqual(meal.proteinGrams, 30.0, "Protein grams should match the initialized value.")
        XCTAssertEqual(meal.imageURL, "https://example.com/chicken.jpg", "Image URL should match the initialized value.")
        XCTAssertEqual(meal.id, "test-id-123", "Meal ID should match the initialized value.")
    }
    
    // Test Meal Initialization with Default Values
    func testMealInitializationWithDefaults() {
        let meal = Meal(name: "Salmon", proteinGrams: 25.0)
        
        XCTAssertEqual(meal.name, "Salmon", "Meal name should match the initialized value.")
        XCTAssertEqual(meal.proteinGrams, 25.0, "Protein grams should match the initialized value.")
        XCTAssertNil(meal.imageURL, "Image URL should be nil when not provided.")
        XCTAssertNotNil(meal.id, "Meal ID should be auto-generated.")
    }
    
    // Test Meal Timestamp Defaults to Current Date
    func testMealTimestampDefault() {
        let meal = Meal(name: "Eggs", proteinGrams: 15.0)
        
        let timeDifference = abs(meal.timestamp.timeIntervalSinceNow)
        XCTAssertLessThan(timeDifference, 1.0, "Timestamp should be set to the current time.")
    }
}
