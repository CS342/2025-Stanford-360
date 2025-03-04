//
//  Patient.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/3/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import Spezi
import SpeziScheduler
import SpeziViews
import UserNotifications

@Observable
final class PatientScheduler: Module, DefaultInitializable, EnvironmentAccessible {
	@Dependency(Scheduler.self) @ObservationIgnored private var scheduler
	
	@MainActor var viewState: ViewState = .idle
	
	private let weeklyWeightNotificationTaskID = "weekly-weight-notification"
	
	init() {}
	
	func configure() {
		scheduleWeeklyWeightNotification()
	}
	
	/// Schedules a notification weekly on Mondays at 9 AM, reminding the user to fill out their "updates" (weight)
	@MainActor
	private func scheduleWeeklyWeightNotification() {
		do {
			try scheduler.createOrUpdateTask(
				id: weeklyWeightNotificationTaskID,
				title: "📝 Weekly Check-In",
				instructions: "Let's keep track of your journey! It's time to fill out your updates.",
				schedule: .weekly(weekday: .saturday, hour: 9, minute: 0, startingAt: .today),
				scheduleNotifications: true
			)
		} catch {
			viewState = .error(AnyLocalizedError(error: error, defaultErrorDescription: "Failed to create or update scheduled tasks."))
		}
	}
}
