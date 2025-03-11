//
//  ProteinPromptConstructorTest.swift
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

final class ProteinPromptConstructorTests: XCTestCase {
    var promptConstructor = ProteinPromptConstructor()

    // Test if constructPrompt() generates the correct format
    func testConstructPrompt() {
        let mealName = "Grilled Chicken"
        let expectedPrompt = """
        You are an expert in nutritional science with a focus on dietary needs for children aged 10-15.

        Task:
        1. Analyze the meal name: "\(mealName)"
        2. Determine the appropriate protein content (in grams) based on nutritional standards for this age group.
        3. Respond with a single numeric value representing the protein content in grams.
        4. Do not include any additional text in your response.
        """

        let result = promptConstructor.constructPrompt(mealName: mealName)
        
        XCTAssertEqual(result, expectedPrompt, "Prompt output does not match expected format.")
    }
    
    // Test if constructPrompt() handles an empty meal name correctly
    func testConstructPromptWithEmptyMealName() {
        let mealName = ""
        let expectedPrompt = """
        You are an expert in nutritional science with a focus on dietary needs for children aged 10-15.

        Task:
        1. Analyze the meal name: "\(mealName)"
        2. Determine the appropriate protein content (in grams) based on nutritional standards for this age group.
        3. Respond with a single numeric value representing the protein content in grams.
        4. Do not include any additional text in your response.
        """

        let result = promptConstructor.constructPrompt(mealName: mealName)
        
        XCTAssertEqual(result, expectedPrompt, "Prompt should handle an empty meal name correctly.")
    }
}
