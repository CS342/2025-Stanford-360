//
//  ProteinWeeklyView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/2/25.
//
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Charts
import SwiftUI

struct ProteinWeekView: View {
	struct DailyProteinData: Identifiable {
		let id = UUID()
		let dayName: String
		let proteinGrams: Double
	}
	
	@Environment(ProteinManager.self) private var proteinManager
	var weeklyData: [DailyProteinData] {
		let calendar = Calendar.current
		let weekdaySymbols = calendar.shortWeekdaySymbols
		var weeklyIntake: [String: Double] = weekdaySymbols.reduce(into: [:]) { $0[$1] = 0 }
		
		for meal in proteinManager.meals where calendar.isDate(meal.timestamp, equalTo: Date(), toGranularity: .weekOfYear) {
			let weekday = calendar.component(.weekday, from: meal.timestamp)
			let dayName = weekdaySymbols[weekday - 1]
			weeklyIntake[dayName, default: 0] += meal.proteinGrams
		}
		
		return weekdaySymbols.map { dayName in
			DailyProteinData(dayName: dayName, proteinGrams: weeklyIntake[dayName] ?? 0)
		}
	}
	
	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("Weekly Protein Intake")
				.font(.headline)
				.foregroundColor(.blue)
			
			Chart {
				ForEach(weeklyData) { data in
					BarMark(
						x: .value("Day", data.dayName),
						y: .value("Protein", data.proteinGrams)
					)
					.foregroundStyle(Color.blue.gradient)
					.opacity(data.proteinGrams > 0 ? 1 : 0)
				}
				
				// Goal line
				goalLine()
			}
//			.chartYAxis {
//				AxisMarks(position: .leading)
//			}
			.chartXAxis {
				AxisMarks(values: weeklyData.map { $0.dayName })
			}
			.chartYScale(domain: 0...100)
			.frame(height: 200)
		}
		.padding()
	}
}

#Preview {
	ProteinWeekView()
}
