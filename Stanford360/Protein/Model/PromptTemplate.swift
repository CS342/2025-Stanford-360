//
//  PromptTemplate.swift
//  Stanford360
//
//  Created /Users/jiayuchang/Desktop/Stanford/cs342/2025-Stanford-360/Stanford360/Protein/Service/LocalLLMService.swiftby jiayu chang on 3/6/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation

class ProteinPromptConstructor: ObservableObject {
    func constructPrompt(mealName: String) -> String {
        let prompt = """
        You are an expert in nutritional science with a focus on dietary needs for children aged 10-15.
        Here are some important information that you can refer:
        1. Those belong to Meats, Poultry, and Fish usually around 6-10 grams.
        2. Those belong to Soy and Vegetable Protein usually around 3-13 grams.
        3. Those belong to Legumes and Nuts usually around 5-10 grams.
        4. Those belong to Milk and Dairy usually around 10 grams.
        5. Those belong to Vegetables usually around 2 grams.
        6. Those belong to Grains usually around 5-10 grams.
        Task:
        1. Analyze the meal name: "\(mealName)"
        2. Determine the appropriate protein content (in grams) based on nutritional standards for this age group.
        3. Respond with a single numeric value representing the protein content in grams.
        4. Do not include any additional text in your response.
        """
        return prompt
    }
}
