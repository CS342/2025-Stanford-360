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

struct ChartData<T> {
	let dates: [Date]
	let dataSource: [Date: T]
	let yLabel: String
	let seriesLabel: String
	let color: Color
	let valueExtractor: (T) -> Double
}

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
			plotLineChart(ChartData(
						dates: filteredActivities,
						dataSource: activityManager.activitiesByDate,
						yLabel: "Activity Minutes",
						seriesLabel: "Activity",
						color: .activityColor,
						valueExtractor: activityManager.getTotalActivityMinutes
					))
					
			plotLineChart(ChartData(
						dates: filteredHydration,
						dataSource: hydrationManager.hydrationByDate,
						yLabel: "Hydration Ounces",
						seriesLabel: "Hydration",
						color: .hydrationColor,
						valueExtractor: hydrationManager.getTotalHydrationOunces
					))
					
			plotLineChart(ChartData(
						dates: filteredMeals,
						dataSource: proteinManager.mealsByDate,
						yLabel: "Protein Grams",
						seriesLabel: "Protein",
						color: .proteinColor,
						valueExtractor: proteinManager.getTotalProteinGrams
					))

//			ForEach(filteredActivities, id: \.self) { date in
//				if let activities = activityManager.activitiesByDate[date] {
//					LineMark(
//						x: .value("Week", date),
//						y: .value("Activity Minutes", activityManager.getTotalActivityMinutes(activities)),
//						series: .value("Metric", "Activity")
//					)
//					.foregroundStyle(Color.activityColor)
//					.symbol {
//						Circle()
//							.fill(Color.activityColor)
//							.frame(width: 8, height: 8)
//					}
//				}
//			}
//			
//			ForEach(filteredHydration, id: \.self) { date in
//				if let hydration = hydrationManager.hydrationByDate[date] {
//					LineMark(
//						x: .value("Week", date),
//						y: .value("Hydration Ounces", hydrationManager.getTotalHydrationOunces(hydration)),
//						series: .value("Metric", "Hydration")
//					)
//					.foregroundStyle(Color.hydrationColor)
//					.symbol {
//						Circle()
//							.fill(Color.hydrationColor)
//							.frame(width: 8, height: 8)
//					}
//				}
//			}
//			
//			ForEach(filteredMeals, id: \.self) { date in
//				if let meals = proteinManager.mealsByDate[date] {
//					LineMark(
//						x: .value("Week", date),
//						y: .value("Protein Grams", proteinManager.getTotalProteinGrams(meals)),
//						series: .value("Metric", "Protein")
//					)
//					.foregroundStyle(Color.proteinColor)
//					.symbol {
//						Circle()
//							.fill(Color.proteinColor)
//							.frame(width: 8, height: 8)
//					}
//				}
//			}
			
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
	
	func plotLineChart<T>(_ chartData: ChartData<T>) -> some ChartContent {
		ForEach(chartData.dates, id: \.self) { date in
			if let data = chartData.dataSource[date] {
				LineMark(
					x: .value("Week", date),
					y: .value(chartData.yLabel, chartData.valueExtractor(data)),
					series: .value("Metric", chartData.seriesLabel)
				)
				.foregroundStyle(chartData.color)
				.symbol {
					Circle()
						.fill(chartData.color)
						.frame(width: 8, height: 8)
				}
			}
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
