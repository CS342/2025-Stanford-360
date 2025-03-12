//
//  ProteinCardView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/10/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProteinCardView: View {
	@Environment(Stanford360Standard.self) private var standard
	@Environment(ProteinManager.self) private var proteinManager
	
	let meal: Meal
	
	var body: some View {
		HStack {
			Text(meal.name)
				.font(.title3.bold())
			
			Spacer()
			
			Text("\(Int(meal.proteinGrams)) g")
				.font(.title3)
				.foregroundStyle(.blue)
		}
		// .background(
		//     RoundedRectangle(cornerRadius: 12)
		//         .fill(Color.white)
		//         .shadow(radius: 2)
		// )
		.padding(16)
		.background(Color.cardBackground)
		.cornerRadius(15)
		.shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 4)
		.swipeActions(edge: .trailing, allowsFullSwipe: true) {
			Button(role: .destructive) {
				Task {
					await standard.deleteMealByID(byID: meal.id ?? "")
					var updatedMeals = proteinManager.meals
					updatedMeals.removeAll { $0.id == meal.id }
					proteinManager.meals = updatedMeals
				}
			} label: {
				Label("Delete", systemImage: "trash")
			}
		}
	}
}

#Preview {
	let meal = Meal(
		name: "Chicken",
		proteinGrams: 20,
		imageURL: "",
		timestamp: Date(),
		id: "sample-id"
	)
	
	ProteinCardView(meal: meal)
}
