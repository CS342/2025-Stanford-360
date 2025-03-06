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

class ProteinPromptConstructor: ObservableObject{
    func constructPrompt(mealName: String) -> String {
        let prompt = """
        You are an expert in nutritional science with a focus on dietary needs for children aged 10-15.

        Task:
        1. Analyze the meal name: "\(mealName)"
        2. Determine the appropriate protein content (in grams) based on nutritional standards for this age group.
        3. Respond with a single numeric value representing the protein content in grams.
        4. Do not include any additional text in your response.
        """
        return prompt
    }
}
