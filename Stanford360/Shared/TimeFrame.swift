//
//  TimeFrame.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/2/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI

/// Defines the time period to display in charts
enum TimeFrame: String, CaseIterable, Identifiable {
	case today = "Today"
	case week = "Week"
	case month = "Month"
	
	var id: String { rawValue }
	
	/// Returns a descriptive title for the time frame
	var title: String {
		switch self {
		case .today: return "Today's Progress"
		case .week: return "Weekly Progress"
		case .month: return "Monthly Progress"
		}
	}
	
	private func getWeek(from today: Date) -> (Date, Date) {
		let calendar = Calendar.current
		
		// find the Monday of the current week
		let weekday = calendar.component(.weekday, from: today)
		let daysToSubtract = (weekday + 5) % 7 // Convert to Monday (weekday 2) being first day of week
		
		guard let startOfWeek = calendar.date(byAdding: .day, value: -daysToSubtract, to: today) else {
			return (today, today)
		}
		
		// end date is Sunday (startOfWeek + 6 days)
		guard let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) else {
			return (startOfWeek, startOfWeek)
		}
		
		return (calendar.startOfDay(for: startOfWeek), calendar.startOfDay(for: endOfWeek))
	}
	
	private func getMonth(from today: Date) -> (Date, Date) {
		let calendar = Calendar.current
		
		// start date is the first day of the current month
		let components = calendar.dateComponents([.year, .month], from: today)
		guard let startOfMonth = calendar.date(from: components) else {
			return (today, today)
		}
		
		// end date is the last day of the current month
		var nextMonthComponents = DateComponents()
		nextMonthComponents.month = 1
		nextMonthComponents.day = -1
		
		guard let endOfMonth = calendar.date(byAdding: nextMonthComponents, to: startOfMonth) else {
			return (startOfMonth, startOfMonth)
		}
		
		return (calendar.startOfDay(for: startOfMonth), calendar.startOfDay(for: endOfMonth))
	}
	
	
	/// Returns a range of dates for the time frame
	func dateRange() -> (start: Date, end: Date) {
		let today = Date()
		
		switch self {
		case .today:
			return (today, today)
		case .week:
			return getWeek(from: today)
		case .month:
			return getMonth(from: today)
		}
	}
}
