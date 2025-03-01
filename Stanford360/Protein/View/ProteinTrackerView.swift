//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

// periphery:ignore - ProteinTrackerView is in progress but it is necessary to merge for class
struct ProteinTrackerView: View {
	// TimeFrame Enum
	enum ProteinTimeFrame {
		case today
		case week
		case month
	}
	
	//    @Environment(Stanford360Standard.self) private var standard
	//    @ObservedObject var proteinData: ProteinManager
	//    @State private var totalProtein: Double // consider this design
	//    @State private var mealName: String = ""
	//    @State private var proteinAmount: Double = 0.0
	//    @State private var showingAddMeal = false
	@State private var isLoading = false
	@State private var isCardAnimating = false
	@State private var isProgressAnimating = false
	@State var selectedTimeFrame: ProteinTimeFrame = .today
	
	var body: some View {
		NavigationView {
			ScrollView {
				VStack(alignment: .leading, spacing: 32) {
					headerView()
					proteinPeriodPicker()
					// proteinPeriodPicker
					switch selectedTimeFrame {
					case .today:
						ProteinProgressView(currentValue: 45, maxValue: 60)
							.frame(height: 250)
							.frame(maxWidth: .infinity, alignment: .center)
					case .week:
						ProteinProgressView(currentValue: 45, maxValue: 60)
							.frame(height: 250)
							.frame(maxWidth: .infinity, alignment: .center)
					case .month:
						ProteinProgressView(currentValue: 45, maxValue: 60)
							.frame(height: 250)
							.frame(maxWidth: .infinity, alignment: .center)
					}
					Spacer()
					mealsCardView()
					// add meal here
				}
				.padding()
			}
			.navigationBarHidden(true)
			.background(Color(UIColor.systemGroupedBackground))
		}
	}
	
	private func headerView() -> some View {
		Text("🍗 Protein Tracker")
			.font(.system(size: 34, weight: .bold, design: .rounded))
			.foregroundColor(.primary)
			.padding(.top)
	}
	
	private func mealsHeaderView() -> some View {
		HStack {
			Text("Daily Meals")
				.font(.title2.bold())
			Spacer()
			Text("2 of 3 Meals") // record meal intake->recommend 6 meals a day
				.font(.subheadline)
				.foregroundStyle(.secondary)
				.padding(.horizontal, 12)
				.padding(.vertical, 6)
				.background(
					Capsule()
						.fill(Color.blue.opacity(0.1))
				)
		}
	}
	
	private func mealsList() -> some View {
		VStack(spacing: 16) {
			mealRowView(
				mealName: "Breakfast",
				protein: "25g",
				time: "8:00 AM",
				isCompleted: true
			)
			
			Divider()
			
			mealRowView(
				mealName: "Lunch",
				protein: "35g",
				time: "12:30 PM",
				isCompleted: true
			)
			
			Divider()
			
			mealRowView(
				mealName: "Dinner",
				protein: "40g",
				time: "7:00 PM",
				isCompleted: false
			)
		}
		.padding()
		.background(
			RoundedRectangle(cornerRadius: 16)
				.fill(Color(UIColor.secondarySystemGroupedBackground))
		)
		.shadow(color: Color.black.opacity(0.05), radius: 10)
	}
	
	private func mealsCardView() -> some View {
		VStack(alignment: .leading, spacing: 20) {
			mealsHeaderView()
			mealsList()
				.opacity(isCardAnimating ? 1 : 0)
				.offset(y: isCardAnimating ? 0 : 50)
				.onAppear {
					withAnimation(.spring(response: 0.8)) {
						isCardAnimating = true
					}
				}
		}
	}
	
	// add picker to change the pick decided by the period
	func proteinPeriodPicker() -> some View {
		Picker("Hydration Period", selection: $selectedTimeFrame) {
			Text("Today").tag(ProteinTimeFrame.today)
			Text("This Week").tag(ProteinTimeFrame.week)
			Text("This Month").tag(ProteinTimeFrame.month)
		}
		.pickerStyle(SegmentedPickerStyle())
		.padding(.horizontal)
	}
	
	private func mealRowView(mealName: String, protein: String, time: String, isCompleted: Bool) -> some View {
		HStack {
			VStack(alignment: .leading, spacing: 4) {
				Text(mealName)
					.font(.headline)
				Text(protein)
					.font(.subheadline)
					.foregroundStyle(.secondary)
			}
			Spacer()
			Text(time)
				.font(.caption)
				.foregroundStyle(.secondary)
				.padding(.trailing, 8)
			Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
				.font(.title3)
				.foregroundStyle(isCompleted ? .blue : .gray.opacity(0.3))
				.symbolEffect(.bounce, value: isCompleted)
				.accessibilityLabel("checkmark")
		}
		.contentShape(Rectangle())
	}
}

#if DEBUG
#Preview {
	ProteinTrackerView()
}
#endif
