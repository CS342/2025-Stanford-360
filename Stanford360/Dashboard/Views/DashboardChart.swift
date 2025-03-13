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
	
	private var dates: [Date] {
		let (startDate, endDate) = timeFrame.dateRange()
		var dates: [Date] = []
		let calendar = Calendar.current
		var currentDate = calendar.startOfDay(for: startDate)
		
		while currentDate <= endDate {
			dates.append(currentDate)
			currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? Date()
		}
		
		return dates
	}
	
	var body: some View {
		Chart {
			ForEach(dates, id: \.self) { date in
				let activities = getActivities(from: date)
				LineMark(
					x: .value("Week", date),
					y: .value("Activity Minutes", activityManager.getTotalActivityMinutes(activities)),
					series: .value("Metric", "Activity")
				)
				.applyChartStyle(color: Color.activityColor)
				
				let hydration = getHydration(from: date)
				LineMark(
					x: .value("Week", date),
					y: .value("Hydration Ounces", hydrationManager.getTotalHydrationOunces(hydration)),
					series: .value("Metric", "Hydration")
				)
				.applyChartStyle(color: Color.hydrationColor)
				
				let meals = getMeals(from: date)
				LineMark(
					x: .value("Week", date),
					y: .value("Protein Grams", proteinManager.getTotalProteinGrams(meals)),
					series: .value("Metric", "Protein")
				)
				.applyChartStyle(color: Color.proteinColor)
			}
			
			goalLine()
		}
		.frame(height: 300)
		.padding(.leading, 40)
		.padding(.trailing, 10)
		.chartXAxis {
			AxisMarks(values: .stride(by: .day)) { value in
				if let date = value.as(Date.self) {
					AxisValueLabel(date.formatted(.dateTime.weekday(.abbreviated)))
				}
			}
		}
	}
	
	private func getActivities(from date: Date) -> [Activity] {
		activityManager.activitiesByDate[date] ?? []
	}
	
	private func getHydration(from date: Date) -> [HydrationLog] {
		hydrationManager.hydrationByDate[date] ?? []
	}
	
	private func getMeals(from date: Date) -> [Meal] {
		proteinManager.mealsByDate[date] ?? []
	}
}

extension LineMark {
	func applyChartStyle(color: Color) -> some ChartContent {
		self
			.foregroundStyle(color)
			.symbol {
				Circle()
					.fill(color)
					.frame(width: 5, height: 5)
			}
	}
}

#Preview {
	@Previewable @State var activityManager = ActivityManager(activities: activitiesData)
	@Previewable @State var hydrationManager = HydrationManager(hydration: hydrationData)
	@Previewable @State var proteinManager = ProteinManager(meals: mealsData)
	
	DashboardChart(timeFrame: .week)
		.environment(activityManager)
		.environment(hydrationManager)
		.environment(proteinManager)
}
