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
		let mealsByDate = proteinManager.mealsByDate
		let dates = mealsByDate.keys.sorted(by: >)
		
		if proteinManager.meals.isEmpty {
			// todo - decompose into "empty state" component
			List {
				Text("No meals logged")
					.foregroundColor(.gray)
					.padding()
			}
			.listStyle(PlainListStyle())
		} else {
			List {
				ForEach(dates, id: \.self) { date in
					Section(header: Text(date.formattedRelative())) {
						ForEach(proteinManager.reverseSortMealsByDate(mealsByDate[date] ?? [])) { meal in
							NavigationLink(destination: MealDetailView(meal: meal)) {
								ProteinCardView(meal: meal)
							}
							.listRowSeparator(.hidden)
						}
					}
				}
			}
			.listStyle(PlainListStyle())
		}
	}
}

#Preview {
	ProteinHistoryView()
}
