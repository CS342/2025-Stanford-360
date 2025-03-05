//
//  DashboardChart.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/2/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Charts
import Foundation
import SwiftUI

struct DashboardChart: View {
	@Environment(ActivityManager.self) private var activityManager
	@Environment(HydrationManager.self) private var hydrationManager
	@Environment(ProteinManager.self) private var proteinManager
	
	var timeFrame: TimeFrame
	
	private var filteredActivities: [Date] {
		let (startDate, endDate) = timeFrame.dateRange()
		return Array(activityManager.activitiesByDate.keys)
			.filter { date in
				date >= startDate && date <= endDate
			}
			.sorted()
	}
	
	private var filteredHydration: [Date] {
		let (startDate, endDate) = timeFrame.dateRange()
		return Array(hydrationManager.hydrationByDate.keys)
			.filter { date in
				date >= startDate && date <= endDate
			}
			.sorted()
	}
	
	private var filteredMeals: [Date] {
		let (startDate, endDate) = timeFrame.dateRange()
		return Array(proteinManager.mealsByDate.keys)
			.filter { date in
				date >= startDate && date <= endDate
			}
			.sorted()
	}
	
	var body: some View {
		Chart {
			ForEach(filteredActivities, id: \.self) { date in
				if let activities = activityManager.activitiesByDate[date] {
					LineMark(
						x: .value("Week", date),
						y: .value("Activity Minutes", activityManager.getTotalActivityMinutes(activities)),
						series: .value("Metric", "Activity")
					)
					.applyChartStyle(color: Color.activityColor)
				}
			}
			
			ForEach(filteredHydration, id: \.self) { date in
				if let hydration = hydrationManager.hydrationByDate[date] {
					LineMark(
						x: .value("Week", date),
						y: .value("Hydration Ounces", hydrationManager.getTotalHydrationOunces(hydration)),
						series: .value("Metric", "Hydration")
					)
					.applyChartStyle(color: Color.hydrationColor)
				}
			}
			
			ForEach(filteredMeals, id: \.self) { date in
				if let meals = proteinManager.mealsByDate[date] {
					LineMark(
						x: .value("Week", date),
						y: .value("Protein Grams", proteinManager.getTotalProteinGrams(meals)),
						series: .value("Metric", "Protein")
					)
					.applyChartStyle(color: Color.proteinColor)
				}
			}
			
			goalLine()
		}
		.frame(height: 300)
		.padding()
		.chartXAxis {
			AxisMarks(values: .automatic) { value in
				if let date = value.as(Date.self) {
					AxisValueLabel {
						Text(date, format: .dateTime.month().day())
					}
				}
			}
		}
		.chartXScale(domain: timeFrame.dateRange().start...timeFrame.dateRange().end)
	}
}

extension LineMark {
	func applyChartStyle(color: Color) -> some ChartContent {
		self
			.foregroundStyle(color)
			.symbol {
				Circle()
					.fill(color)
					.frame(width: 8, height: 8)
			}
	}
}

#Preview {
	@Previewable @State var activityManager = ActivityManager(activities: activitiesData)
	@Previewable @State var proteinManager = ProteinManager(meals: mealsData)
	
	DashboardChart(timeFrame: .month)
		.environment(activityManager)
		.environment(proteinManager)
}
