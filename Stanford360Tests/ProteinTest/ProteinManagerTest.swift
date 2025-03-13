// periphery:ignore:all
//
//  ProteinManagerTest.swift
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

final class ProteinManagerTests: XCTestCase {
    func testGetTodayTotalGrams() {
        let today = Date()
        let meal1 = Meal(name: "Chicken", proteinGrams: 20, imageURL: "", timestamp: today, id: "1")
        let meal2 = Meal(name: "Fish", proteinGrams: 30, imageURL: "", timestamp: today, id: "2")
        let meal3 = Meal(name: "Beef", proteinGrams: 10, imageURL: "", timestamp: today, id: "3")
        
        let manager = ProteinManager(meals: [meal1, meal2, meal3])
        XCTAssertEqual(manager.getTodayTotalGrams(), 60.0, "Total protein grams should be 60")
    }

    func testGetTotalProteinGrams() {
        let meal1 = Meal(name: "Eggs", proteinGrams: 12, imageURL: "", timestamp: Date(), id: "4")
        let meal2 = Meal(name: "Steak", proteinGrams: 25, imageURL: "", timestamp: Date(), id: "5")
        
        let totalGrams = ProteinManager().getTotalProteinGrams([meal1, meal2])
        XCTAssertEqual(totalGrams, 37.0, "Total protein grams should be 37")
    }

    func testReverseSortMealsByDate() {
        let meal1 = Meal(name: "Breakfast", proteinGrams: 15, imageURL: "", timestamp: Date().addingTimeInterval(-3600), id: "6")
        let meal2 = Meal(name: "Lunch", proteinGrams: 20, imageURL: "", timestamp: Date(), id: "7")
        
        let sortedMeals = ProteinManager().reverseSortMealsByDate([meal1, meal2])
        XCTAssertEqual(sortedMeals.first?.name, "Lunch", "Meals should be sorted in descending order of timestamp")
    }

    func testStreakCalculation() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
              let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today) else {
            fatalError("Failed to calculate dates")
        }
        
        let meal1 = Meal(name: "Day 1", proteinGrams: 60, imageURL: "", timestamp: today, id: "8")
        let meal2 = Meal(name: "Day 2", proteinGrams: 60, imageURL: "", timestamp: yesterday, id: "9")
        let meal3 = Meal(name: "Day 3", proteinGrams: 50, imageURL: "", timestamp: twoDaysAgo, id: "10")
        
        let manager = ProteinManager(meals: [meal1, meal2, meal3])
        XCTAssertEqual(manager.streak, 2, "Streak should be 2 days")
    }
    
//    func testTriggerMotivation() {
//        let meal1 = Meal(name: "Omelette", proteinGrams: 40, imageURL: "", timestamp: Date(), id: "11")
//        let manager = ProteinManager(meals: [meal1])
//        let motivationMessage = manager.triggerMotivation()
//        
//        XCTAssertTrue(motivationMessage.contains("Keep going"), "Message should encourage the user to reach 60g")
//    }
}
