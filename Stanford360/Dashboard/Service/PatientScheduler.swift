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
final class PatientScheduler: Module, DefaultInitializable, EnvironmentAccessible, NotificationHandler {
	@Dependency(Scheduler.self) @ObservationIgnored private var scheduler
	@Dependency(AppNavigationState.self) @ObservationIgnored private var navigationState
	
	@MainActor var viewState: ViewState = .idle
	
	private let saturdayWeightNotificationTaskID = "saturday-weight-notification"
	private let sundayWeightNotificationTaskID = "sunday-weight-notification"
	
	init() {}
	
	func configure() {
		// this notification will be cancelled if the user logs their weight on Saturday before 9 AM
		scheduleWeeklyWeightNotifications(
			taskId: saturdayWeightNotificationTaskID,
			weekday: .saturday
		)
		
		// this notification will be cancelled if the user logs their weight on Saturday or before Sunday 9 AM
		scheduleWeeklyWeightNotifications(
			taskId: saturdayWeightNotificationTaskID,
			weekday: .sunday
		)
	}
	
	/// Schedules notifications weekly on Saturday and Sundays at 9 AM, reminding the user to fill out their "updates" (weight)
	@MainActor
	private func scheduleWeeklyWeightNotifications(taskId: String, weekday: Locale.Weekday) {
		do {
			try scheduler.createOrUpdateTask(
				id: taskId,
				title: "📝 Weekly Check-In",
				instructions: "Let's keep track of your journey! It's time to fill out your updates.",
				schedule: .weekly(weekday: weekday, hour: 9, minute: 0, startingAt: .today),
				scheduleNotifications: true
			)
		} catch {
			viewState = .error(AnyLocalizedError(error: error, defaultErrorDescription: "Failed to create or update scheduled tasks."))
		}
	}
	
	func handleNotificationAction(_ response: UNNotificationResponse) {
		print("✅ handleNotificationAction called with response: \(response)")
		
		let userInfo = response.notification.request.content.userInfo
		print("🔍 userInfo: \(userInfo)")
		
		if let taskId = userInfo["edu.stanford.spezi.scheduler.notification.taskId"] as? String {
			print("✅ Extracted taskId: \(taskId)")
			navigateToView(for: taskId)
		} else {
			print("❌ Failed to extract taskId")
		}
	}
	
	@MainActor
	private func navigateToView(for taskId: String) {
		switch taskId {
		case saturdayWeightNotificationTaskID, sundayWeightNotificationTaskID:
			print("✅ Setting showAccountSheet to true")
			navigationState.showAccountSheet = true
		default:
			break
		}
	}
	
	
	/// Handles notifications after a user has logged their weight
	///
	/// If the user logs their weight on Saturday before the 9 AM notification, this function will
	/// clears both notifications
	/// If the user logs their weight in between the Saturday and Sunday 9 AM notification, this
	/// function will clear the Sunday notification
	@MainActor
	func maybeClearNotifications(loggedWeightTimestamp: Date) {
		let weekday = Calendar.current.component(.weekday, from: loggedWeightTimestamp)
		
		// if the user logged weight saturday or sunday, clear notifications
		if weekday == 7 || weekday == 1 {
			do {
				let scheduledTasksToClear = try scheduler.queryTasks(
					for: Date()..<Date().addingTimeInterval(60 * 60 * 24 * 2), // at most, need the next 2 days
					predicate: #Predicate { $0.id == saturdayWeightNotificationTaskID || $0.id == sundayWeightNotificationTaskID }
				)
				
				try scheduler.deleteTasks(scheduledTasksToClear)
			} catch {
				print("There was an error querying or deleting tasks: \(error)")
			}
		}
	}
}
