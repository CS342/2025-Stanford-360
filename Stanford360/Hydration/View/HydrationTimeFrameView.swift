//
//  HydrationTimeFrameView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/4/25.
//

import Charts
import SwiftUI

struct HydrationTimeFrameView: View {
	@Environment(Stanford360Standard.self) var standard
	@Environment(HydrationManager.self) var hydrationManager
	
	@State private var selectedTimeFrame: TimeFrame = .today
	@State private var selectedAmountOunces: Double?
	
	var body: some View {
		VStack {
			TimeFramePicker(selectedTimeFrame: $selectedTimeFrame)
			
			TabView(selection: $selectedTimeFrame) {
				todayView
					.tag(TimeFrame.today)
				weeklyView()
					.tag(TimeFrame.week)
				monthlyView()
					.tag(TimeFrame.month)
			}
			.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
			
			// non-swipeable bottom half of tabs
			switch selectedTimeFrame {
			case .today:
				todayViewBottom
			case .week:
//				todayViewBottom
				Spacer()
				//				weeklyViewList
			case .month:
//				todayViewBottom
				Spacer()
				//				monthlyViewList
			}
		}
	}
	
	private var weeklyFilteredHydration: [Date] {
		let (startDate, endDate) = TimeFrame.week.dateRange()
		return Array(hydrationManager.hydrationByDate.keys)
			.filter { date in
				date >= startDate && date <= endDate
			}
			.sorted()
	}
	
	private var monthlyFilteredHydration: [Date] {
		let (startDate, endDate) = TimeFrame.month.dateRange()
		return Array(hydrationManager.hydrationByDate.keys)
			.filter { date in
				date >= startDate && date <= endDate
			}
			.sorted()
	}
	
	private var todayView: some View {
		VStack(spacing: 20) {
			VStack {
				DailyProgressView(activeMinutes: Int(hydrationManager.getTodayHydrationOunces()))
					.frame(height: 200)
					.padding(.top, 20)
			}
		}
	}
	
	private var todayViewBottom: some View {
		VStack {
			VStack {
				HStack {
					cardButton(imageName: "small_mug", text: "8 oz", ounces: 8)
					cardButton(imageName: "large_mug", text: "10 oz", ounces: 10)
					cardButton(imageName: "medium_mug", text: "12 oz", ounces: 12)
				}
				HStack {
					cardButton(imageName: "small_water", text: "16 oz", ounces: 16)
					cardButton(imageName: "medium_water", text: "20 oz", ounces: 20)
					cardButton(imageName: "large_water", text: "32 oz", ounces: 32)
				}
			}
			
			logButton()
		}
	}
	
	func cardButton(imageName: String, text: String, ounces: Double) -> some View {
		Button(action: {
			selectedAmountOunces = (selectedAmountOunces == ounces) ? nil : ounces
		}) {
			VStack {
				Image(imageName)
					.resizable()
					.scaledToFit()
					.frame(width: 30, height: 40)
					.accessibilityLabel(text)
				
				Text(text)
					.font(.headline)
					.foregroundColor(.primary)
			}
			.frame(width: 90, height: 90)
			.background(
				RoundedRectangle(cornerRadius: 10)
					.fill(Color.white)
					.overlay(
						RoundedRectangle(cornerRadius: 10)
							.stroke(selectedAmountOunces == ounces ? Color.blue : Color.clear, lineWidth: 3)
					)
					.shadow(radius: 3)
			)
			
			.padding(5)
		}
	}
	
	func logButton() -> some View {
		Button(action: {
			guard selectedAmountOunces != nil else {
				print("select a water amount")
				return
			}
			
			print("selected ounces: \(selectedAmountOunces ?? 0)")
			Task {
				await logWaterIntake()
			}
		}) {
			Text("Log Water Intake")
				.fontWeight(.bold)
				.frame(maxWidth: .infinity)
				.padding()
				.background(
					LinearGradient(
						colors: [
							Color.blue,
							Color.blue.opacity(0.8)
						],
						startPoint: .leading,
						endPoint: .trailing
					)
				)
				.foregroundColor(.white)
				.cornerRadius(12)
				.shadow(radius: 3)
		}
		.padding(.horizontal)
		.accessibilityIdentifier("logWaterIntakeButton")
		.accessibilityLabel("Log your water intake")
	}
	
	func logWaterIntake() async {
		print("Logging water intake...")
		let hydrationIntake = HydrationIntake(
			hydrationOunces: selectedAmountOunces ?? 0,
			streak: 0,
			lastTriggeredMilestone: 0,
			lastHydrationDate: Date(),
			isStreakUpdated: false
		)
		
		hydrationManager.hydration.append(hydrationIntake)
		await standard.storeHydrationIntake(hydrationIntake)
	}
	
	// MARK: - Weekly Hydration View
	func weeklyView() -> some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("Weekly Hydration")
				.font(.headline)
				.foregroundColor(.blue)
			
			weeklyChart()
			//				.overlay(hoverTooltip())
			//				.chartOverlay { proxy in
			//					chartHoverGesture(proxy: proxy)
			//				}
		}
		.padding()
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
	}
	
	// MARK: - Weekly Chart View
	func weeklyChart() -> some View {
		Chart {
			ForEach(weeklyFilteredHydration, id: \.self) { date in
				if let hydration = hydrationManager.hydrationByDate[date] {
					BarMark(
						x: .value("Day", date),
						y: .value("Intake", hydrationManager.getTotalHydrationOunces(hydration))
					)
					.foregroundStyle(Color.blue.gradient)
					.opacity(hydrationManager.getTotalHydrationOunces(hydration) > 0 ? 1 : 0)
				}
			}
			
			// Goal line
			goalLine()
		}
		.chartXAxis {
			AxisMarks(values: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"])
		}
		.chartYScale(domain: 0...100) // come back and make y scale range end at max intake for the week
		.frame(height: 200)
	}
	
	//	// MARK: - Chart Hover Gesture
	//	private func chartHoverGesture(proxy: ChartProxy) -> some View {
	//		Color.clear
	//			.contentShape(Rectangle())
	//			.gesture(
	//				DragGesture(minimumDistance: 0)
	//					.onChanged { value in
	//						let location = value.location
	//						if let closestData = findClosestWeeklyData(to: location, in: proxy) {
	//							selectedDate = closestData.dayName
	//							selectedIntake = closestData.intakeOz
	//							selectedPosition = location
	//						}
	//					}
	//					.onEnded { _ in
	//						DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
	//							selectedDate = nil
	//							selectedIntake = nil
	//							selectedPosition = nil
	//						}
	//					}
	//			)
	//	}
	//
	//	// MARK: - Find Closest Weekly Data Point
	//	private func findClosestWeeklyData(to location: CGPoint, in proxy: ChartProxy) -> DailyHydrationData? {
	//		guard !weeklyData.isEmpty else {
	//			return nil
	//		}
	//
	//		if let dayName = proxy.value(atX: location.x, as: String.self) {
	//			return weeklyData.first(where: { $0.dayName == dayName })
	//		}
	//
	//		return nil
	//	}
	//
	// MARK: - Monthly Hydration View
	func monthlyView() -> some View {
		VStack(alignment: .leading) {
			Text("Monthly Hydration")
				.font(.headline)
				.foregroundColor(.blue)
			
			monthlyChart()
			//				.overlay(hoverTooltip())
			//				.chartOverlay { proxy in
			//					Color.clear
			//						.contentShape(Rectangle())
			//						.gesture(
			//							DragGesture(minimumDistance: 0)
			//								.onChanged { value in
			//									let location = value.location
			//									if let closestData = findClosestData(to: location, in: proxy) {
			//										selectedDate = closestData.dayName
			//										selectedIntake = closestData.intakeOz
			//										selectedPosition = location
			//									}
			//								}
			//								.onEnded { _ in
			//									DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
			//										selectedDate = nil
			//										selectedIntake = nil
			//										selectedPosition = nil
			//									}
			//								}
			//						)
			//		}
		}
		.padding()
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
	}
	
	// MARK: - Chart View
	private func monthlyChart() -> some View {
		Chart {
			ForEach(monthlyFilteredHydration, id: \.self) { date in
				if let hydration = hydrationManager.hydrationByDate[date] {
					LineMark(
						x: .value("Date", date),
						y: .value("Intake", hydrationManager.getTotalHydrationOunces(hydration))
					)
					.interpolationMethod(.monotone)
					.foregroundStyle(.blue.gradient)
				}
			}
			
			// Goal Line at 60 oz
			goalLine()
		}
		.chartYScale(domain: 0...100 /*maxMonthlyIntake*/) // todo(kelly) - revert this back to maxMontlhyIntake
		.chartXAxis {
			AxisMarks(values: .automatic) { _ in }
		}
		.frame(height: 200)
	}
	//
	//	// MARK: - Find Closest Data Point (Fix Hover)
	//	private func findClosestData(to location: CGPoint, in proxy: ChartProxy) -> DailyHydrationData? {
	//		guard !monthlyData.isEmpty else {
	//			return nil
	//		}
	//
	//		if let dayName = proxy.value(atX: location.x, as: String.self) {
	//			return monthlyData.first(where: { $0.dayName == dayName })
	//		}
	//
	//		return nil
	//	}
	//
	//	// MARK: - Tooltip Overlay (Fix: Now Properly Displays)
	//	private func hoverTooltip() -> some View {
	//		GeometryReader { _ in
	//			if let selectedDate, let selectedIntake, let selectedPosition {
	//				VStack {
	//					Text("\(selectedDate): \(selectedIntake, specifier: "%.1f") oz")
	//						.font(.caption)
	//						.bold()
	//						.foregroundColor(.white)
	//						.padding(6)
	//						.background(RoundedRectangle(cornerRadius: 10).fill(Color.blue))
	//						.position(x: selectedPosition.x, y: max(selectedPosition.y - 40, 20))
	//				}
	//			}
	//		}
	//	}
	
}

#Preview {
	HydrationTimeFrameView()
}
