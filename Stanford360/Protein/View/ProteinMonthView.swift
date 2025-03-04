//
//  ProteinMonthView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/2/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Charts
import SwiftUI

struct ProteinMonthView: View {
	struct MonthlyProteinData: Identifiable {
		let id = UUID()
		let monthName: String
		let proteinGrams: Double
	}
	
	@Environment(ProteinManager.self) private var proteinManager
	var monthlyData: [MonthlyProteinData] {
		let calendar = Calendar.current
		var monthlyIntake: [String: Double] = [:]
		
		for meal in proteinManager.meals {
			let monthIndex = calendar.component(.month, from: meal.timestamp) - 1
			let monthName = Calendar.current.shortMonthSymbols[monthIndex]
			monthlyIntake[monthName, default: 0] += meal.proteinGrams
		}
		
		return Calendar.current.shortMonthSymbols.map { monthName in
			MonthlyProteinData(monthName: monthName, proteinGrams: monthlyIntake[monthName] ?? 0)
		}
	}
	
	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("Yearly Protein Intake")
				.font(.headline)
				.foregroundColor(.blue)
			
			Chart {
				ForEach(monthlyData) { data in
					LineMark(
						x: .value("Month", data.monthName),
						y: .value("Protein", data.proteinGrams)
					)
					.interpolationMethod(.monotone)
					.foregroundStyle(.blue)
				}
				
				goalLine()
			}
			.chartXAxis {
				AxisMarks(values: Calendar.current.shortMonthSymbols) { value in
					AxisGridLine()
					AxisTick()
					if let month = value.as(String.self) {
						AxisValueLabel {
							Text(month)
						}
					}
				}
			}
			.chartYScale(domain: 0...200)
			.frame(height: 200)
		}
		.padding()
	}
}

#Preview {
	ProteinMonthView()
}
