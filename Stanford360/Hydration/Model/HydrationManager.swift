//
//  HydrationManager.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 2/28/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import Spezi

class HydrationManager: Module, EnvironmentAccessible {
	var hydration: [HydrationLog]
	
	init(hydration: [HydrationLog] = []) {
		self.hydration = hydration
	}
	
	func getTodayHydrationOunces() -> Double {
		let calendar = Calendar.current
		let today = calendar.startOfDay(for: Date())
		
		return hydration
			.filter { calendar.isDate($0.lastHydrationDate, inSameDayAs: today) }
			.reduce(0) { $0 + $1.amountOz }
	}
}
