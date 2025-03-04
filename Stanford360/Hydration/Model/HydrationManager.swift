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

@Observable
class HydrationManager: Module, EnvironmentAccessible {
	var hydration: [HydrationIntake]
	var hydrationByDate: [Date: [HydrationIntake]] {
		var hydrationByDate: [Date: [HydrationIntake]] = [:]
		for hydrationIntake in hydration {
			let normalizedDate = Calendar.current.startOfDay(for: hydrationIntake.lastHydrationDate)
			hydrationByDate[normalizedDate, default: []].append(hydrationIntake)
		}
		
		return hydrationByDate
	}
	
	init(hydration: [HydrationIntake] = []) {
		self.hydration = hydration
	}
	
	func getTodayHydrationOunces() -> Double {
		let calendar = Calendar.current
		let today = calendar.startOfDay(for: Date())
		
		return hydration
			.filter { calendar.isDate($0.lastHydrationDate, inSameDayAs: today) }
			.reduce(0) { $0 + $1.hydrationOunces }
	}
	
	func getTotalHydrationOunces(_ hydration: [HydrationIntake]) -> Double {
		hydration.reduce(0) { $0 + $1.hydrationOunces }
	}
}
