//
//  HydrationTodayView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/4/25.
//

import SwiftUI

struct HydrationTodayView: View {
	@Environment(Stanford360Standard.self) var standard
	@Environment(HydrationManager.self) var hydrationManager
	
	@State private var selectedAmountOunces: Double?
	
	var body: some View {
		VStack(spacing: 20) {
			VStack {
				DailyProgressView(activeMinutes: Int(hydrationManager.getTodayHydrationOunces()))
					.frame(height: 200)
					.padding(.top, 20)
			}
			
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
			//			streakDisplay()
			//			errorDisplay()
			//			suggestionDisplay()
			//			milestoneMessageView()
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
					.frame(width: 40, height: 50)
					.accessibilityLabel(text)
				
				Text(text)
					.font(.headline)
					.foregroundColor(.primary)
			}
			.frame(width: 100, height: 100)
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
	
	// MARK: - Log Button
	func logButton() -> some View {
		Button(action: {
			guard selectedAmountOunces != nil else {
				print("select a water amount")
				return
			}
			
			print("selected ounces: \(selectedAmountOunces)")
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
		
		await standard.storeHydrationIntake(hydrationIntake)
	}
	
	//
	//	// MARK: - Streak Display
	//	func streakDisplay() -> some View {
	//		VStack {
	//			if let streak = streak, streak > 0 {
	//				HStack {
	//					Image(systemName: "flame.fill")
	//						.foregroundColor(.orange)
	//						.accessibilityLabel("Streak icon")
	//					Text("\(streak) Day Streak")
	//						.font(.headline)
	//						.foregroundColor(.orange)
	//						.scaleEffect(streakJustUpdated ? 1.2 : 1.0)
	//						.opacity(streakJustUpdated ? 1.0 : 0.8)
	//						.animation(.spring(response: 0.4, dampingFraction: 0.6), value: streakJustUpdated)
	//				}
	//				.padding(10)
	//				.background(RoundedRectangle(cornerRadius: 12).fill(Color.orange.opacity(0.2)).shadow(radius: 2))
	//				.transition(.scale)
	//				.accessibilityIdentifier("streakLabel")
	//			} else {
	//				EmptyView()
	//			}
	//		}
	//	}
	//
	//
	//	// MARK: - Log Button
	//	func logButton() -> some View {
	//		Button(action: {
	//			guard let selected = selectedAmount else {
	//				errorMessage = "❌ Please select an amount first."
	//				return
	//			}
	//			intakeAmount = String(selected)
	//			let hydrationIntake = HydrationIntake(
	//				hydrationOunces: Double(intakeAmount) ?? 0,
	//				streak: 0,
	//				lastTriggeredMilestone: 0,
	//				lastHydrationDate: Date(),
	//				isStreakUpdated: false
	//			)
	//
	//			hydrationManager.hydration.append(hydrationIntake)
	//
	//			Task {
	//				await standard.storeHydrationIntake(hydrationIntake)
	////                await logWaterIntake()
	//			}
	//		}) {
	//			Text("Log Water Intake")
	//				.fontWeight(.bold)
	//				.frame(maxWidth: .infinity)
	//				.padding()
	//				.background(
	//					LinearGradient(
	//						colors: [
	//							Color.blue,
	//							Color.blue.opacity(0.8)
	//						],
	//						startPoint: .leading,
	//						endPoint: .trailing
	//					)
	//				)
	//				.foregroundColor(.white)
	//				.cornerRadius(12)
	//				.shadow(radius: 3)
	//		}
	//		.padding(.horizontal)
	//		.accessibilityIdentifier("logWaterIntakeButton")
	//		.accessibilityLabel("Log your water intake")
	//	}
	//
	//	// MARK: - Error Display
	//	func errorDisplay() -> some View {
	//		Group {
	//			if let errorMessage = errorMessage {
	//				Text(errorMessage)
	//					.foregroundColor(.red)
	//					.font(.subheadline)
	//					.accessibilityIdentifier("errorMessageLabel")
	//			}
	//		}
	//	}
	//
	//	// MARK: - Milestone Message View
	//	func milestoneMessageView() -> some View {
	//		if let milestoneMessage = milestoneMessage {
	//			return AnyView(
	//				Text(milestoneMessage)
	//					.foregroundColor(isSpecialMilestone ? .orange : .blue)
	//					.font(.headline)
	//					.multilineTextAlignment(.center)
	//					.lineLimit(nil)
	//					.padding(12)
	//					.background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 2))
	//					.transition(.scale)
	//					.accessibilityIdentifier("milestoneMessageLabel")
	//			)
	//		} else {
	//			return AnyView(EmptyView())
	//		}
	//	}
	//
	//	// MARK: - Goal Suggestion Display
	//	func suggestionDisplay() -> some View {
	//		if totalIntake < 60 {
	//			return AnyView(
	//				Text("You need \(String(format: "%.1f", 60 - totalIntake)) oz more to reach your goal!")
	//					.font(.subheadline)
	//					.foregroundColor(.secondary)
	//					.accessibilityIdentifier("suggestionLabel")
	//			)
	//		} else {
	//			return AnyView(
	//				Text("🎉 Goal Reached! Stay Hydrated! 🎉")
	//					.font(.subheadline)
	//					.foregroundColor(.green)
	//					.bold()
	//					.accessibilityIdentifier("goalReachedLabel")
	//			)
	//		}
	//	}
}

#Preview {
	@Previewable @State var standard = Stanford360Standard()
	@Previewable @State var hydrationManager = HydrationManager()
	HydrationTodayView()
		.environment(standard)
		.environment(hydrationManager)
}
