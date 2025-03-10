//
//  ProteinHistoryView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/10/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProteinHistoryView: View {
	@Environment(ProteinManager.self) private var proteinManager
	
    var body: some View {
		let meals = proteinManager.meals
		let reverseSortedMeals = proteinManager.reverseSortMealsByDate(meals)
		
		if meals.isEmpty {
				// todo - decompose into "empty state" component
				List {
					Text("No meals logged today")
						.foregroundColor(.gray)
						.padding()
				}
				.listStyle(PlainListStyle())
		} else {
			List {
				ForEach(reverseSortedMeals) { meal in
					NavigationLink(destination: MealDetailView(meal: meal)) {
						ProteinCardView(meal: meal)
					}
					.simultaneousGesture(
						DragGesture(minimumDistance: 5)
							.onChanged { value in
								let isHorizontalDrag = abs(value.translation.width) > abs(value.translation.height)
								let isQuickSwipe = abs(value.translation.width) < 20
								
								// If it's a quick, short horizontal swipe, let it through
								// as it's likely attempting to access the swipe actions
								if isHorizontalDrag && !isQuickSwipe {
									// Consume the gesture to prevent TabView swiping
								}
							}
					)
				}
			}
			.listStyle(PlainListStyle())
		}
    }
}

#Preview {
    ProteinHistoryView()
}
