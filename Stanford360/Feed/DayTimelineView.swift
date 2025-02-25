//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
//  DayTimelineView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 2/24/25.
//

import SwiftUI

struct DayTimelineView: View {
	@State private var taskStore = TaskStore()
	@State private var currentDate = Date()
	@State private var selectedDayOffset = 0
	@Binding var selectedTab: HomeView.Tabs
	
	private let daysToShowEachSide = 500
	
	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			// Timeline header
			Text("Timeline")
				.font(.headline)
				.padding(.horizontal)
				.padding(.top, 8)
				.padding(.bottom, 4)
			
			// Timeline scrollable row
			ScrollViewReader { scrollProxy in
				ScrollView(.horizontal, showsIndicators: false) {
					LazyHStack(spacing: 18) {
						ForEach(-daysToShowEachSide...daysToShowEachSide, id: \.self) { dayOffset in
							dayView(for: dayOffset)
								.id(dayOffset)
								.onTapGesture {
									selectedDayOffset = dayOffset
								}
						}
					}
					.padding(.horizontal)
					.padding(.vertical, 8)
				}
				.background(Color.gray.opacity(0.05))
				.cornerRadius(12)
				.padding(.horizontal)
				.onAppear {
					// Initially center on current day (offset 0)
					scrollProxy.scrollTo(0, anchor: .center)
				}
			}
			
			// Add spacing between timeline and daily schedule
			Spacer().frame(height: 20)
			
			// Daily schedule for the selected day
			let selectedDate = Calendar.current.date(byAdding: .day, value: selectedDayOffset, to: currentDate) ?? currentDate
			DailyScheduleView(
				date: selectedDate,
				taskStore: taskStore,
				selectedTab: $selectedTab
			)
			.padding(.horizontal)
		}
		.padding(.vertical)
	}
	
	private func dayView(for dayOffset: Int) -> some View {
		let date = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentDate) ?? Date()
		let isToday = Calendar.current.isDateInToday(date)
		let isSelected = dayOffset == selectedDayOffset
		let weekday = Calendar.current.component(.weekday, from: date)
		let dayInMonth = Calendar.current.component(.day, from: date)
		
		// Check if all tasks for this day are completed
		let allTasksCompleted = taskStore.areAllTasksCompletedForDate(date)
		
		return VStack(spacing: 4) {
			// Day indicator circle with completion status
			ZStack {
				Circle()
					.fill(allTasksCompleted ? Color.teal : (isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2)))
					.frame(width: 36, height: 36)
					.overlay(
						Circle()
							.stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
					)
				
				if isToday && !allTasksCompleted {
					Circle()
						.trim(from: 0, to: 0.7)
						.stroke(Color.teal, lineWidth: 2)
						.frame(width: 36, height: 36)
						.rotationEffect(.degrees(-90))
				}
				
				if allTasksCompleted {
    Image(systemName: "checkmark")
            .foregroundColor(.white)
            .font(.system(size: 12, weight: .bold))
            .accessibilityLabel("Task completed for day \(dayInMonth)")
				} else {
					// Show day number inside circle for non-completed days
					Text("\(dayInMonth)")
						.font(.system(size: 12, weight: .medium))
						.foregroundColor(isSelected ? .blue : (isToday ? .teal : .gray))
				}
			}
			
			// Weekday abbreviation
			Text(weekdayAbbreviation(for: weekday))
				.font(.caption)
				.foregroundColor(isSelected ? .blue : (isToday ? .teal : .gray))
			
			// Small dot indicator for today or selected
			if isToday || isSelected {
				Circle()
					.fill(isSelected ? Color.blue : Color.teal)
					.frame(width: 4, height: 4)
			}
		}
		.padding(.vertical, 4)
		.padding(.horizontal, 4)
		.background(isSelected ? Color.blue.opacity(0.05) : Color.clear)
		.cornerRadius(8)
	}
	
	private func weekdayAbbreviation(for weekday: Int) -> String {
		let weekdays = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
		// Adjust index because Calendar.weekday is 1-based (1 = Sunday, 2 = Monday, etc.)
		return weekdays[weekday - 1]
	}
}

#Preview {
	@Previewable @State var selectedTab = HomeView.Tabs.home
	
	DayTimelineView(selectedTab: $selectedTab)
}
