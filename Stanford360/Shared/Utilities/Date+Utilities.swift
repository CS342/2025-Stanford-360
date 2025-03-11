//
//  Date+Utilities.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/10/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation

extension Date {
	func formattedRelative() -> String {
		let calendar = Calendar.current
		
		if calendar.isDateInToday(self) {
			return "Today"
		} else if calendar.isDateInYesterday(self) {
			return "Yesterday"
		} else {
			let formatter = DateFormatter()
			
			let currentYear = calendar.component(.year, from: Date())
			let dateYear = calendar.component(.year, from: self)
			
			if dateYear == currentYear {
				formatter.dateFormat = "EEE MMM d" // e.g., "Mon Mar 10"
			} else {
				formatter.dateFormat = "EEE MMM d, yyyy" // e.g., "Wed Mar 10, 2025"
			}
			
			return formatter.string(from: self)
		}
	}
}
