//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
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
final class ActivityScheduler: Module, DefaultInitializable, EnvironmentAccessible {
	@Dependency(Scheduler.self) @ObservationIgnored private var scheduler
	
	@MainActor var viewState: ViewState = .idle
	
	private let belowHalfActivity5PMNotificationTaskID = "below-half-activity-5pm-notif"
	private let halfActivity5PMNotificationTaskID = "half-activity-5pm-notif"
	private let fullActivity5PMNotificationTaskID = "full-activity-5pm-notif"
	private let halfActivity8PMNotificationTaskID = "half-activity-8pm-notif"
	private let halfActivityImmediateNotificationTaskID = "half-activity-immediate-notif"
	private let fullActivityImmediateNotificationTaskID = "full-activity-immediate-notif"
	
	private let scheduleDaily5PM: Schedule = .daily(hour: 17, minute: 0, startingAt: .today)
	private let scheduleDaily8PM: Schedule = .daily(hour: 20, minute: 0, startingAt: .today)
	
	private let dateRange1Day: Range<Date> = Date()..<Date().addingTimeInterval(60 * 60 * 24 * 1)
	
	init() {}
	
	func configure() {
		// Schedules a notification every day at 5 PM encouraging the user to complete their 60 minutes of activity
		scheduleNotification(
			taskId: belowHalfActivity5PMNotificationTaskID,
			title: "Let's get moving!",
			instructions: "Don't forget your 60 minutes of daily activity!",
			schedule: scheduleDaily5PM
		)
	}
	
	@MainActor
	func scheduleNotification(
		taskId: String,
		title: String.LocalizationValue,
		instructions: String.LocalizationValue,
		schedule: Schedule
	) {
		do {
			try scheduler.createOrUpdateTask(
				id: taskId,
				title: title,
				instructions: instructions,
				schedule: schedule,
				scheduleNotifications: true
			)
		} catch {
			viewState = .error(AnyLocalizedError(error: error, defaultErrorDescription: "Failed to create or update scheduled tasks."))
		}
	}
	
	@MainActor
	func clearNotification(taskIds: [String], for timeRange: Range<Date>) {
		do {
			let scheduledTasksToClear = try scheduler.queryTasks(
				for: timeRange,
				predicate: #Predicate { taskIds.contains($0.id) }
			)
			
			try scheduler.deleteTasks(scheduledTasksToClear)
		} catch {
			print("There was an error querying or deleting tasks: \(error)")
		}
	}
	
	@MainActor
	func clearOutdatedNotifications() {
		clearNotification(
			taskIds: [belowHalfActivity5PMNotificationTaskID, halfActivity5PMNotificationTaskID, halfActivity8PMNotificationTaskID],
			for: dateRange1Day
		)
	}
	
	@MainActor
	func scheduleHalfwayNotifications(schedule: Schedule, newActivityMinutes: Int) {
		scheduleNotification(
			taskId: halfActivity5PMNotificationTaskID,
			title: "Keep going!",
			instructions: "You're halfway there!",
			schedule: schedule
		)
		scheduleNotification(
			taskId: halfActivity8PMNotificationTaskID,
			title: "Almost done!",
			instructions: "You have \(60 - newActivityMinutes) minutes of activity remaining!",
			schedule: scheduleDaily8PM
		)
	}
	
	@MainActor
	func scheduleCompletionNotification(taskId: String, schedule: Schedule) {
		scheduleNotification(
			taskId: taskId,
			title: "Congrats!",
			instructions: "You've completed 60 minutes of activity!",
			schedule: schedule
		)
	}
	
	
	@MainActor
	func handleNotificationsOnLoggedActivity(prevActivityMinutes: Int, newActivityMinutes: Int) async {
		let now = Date()
		let calendar = Calendar.current
		let hour = calendar.component(.hour, from: now)
		let scheduleImmediate: Schedule = .once(at: now)
		let justReached30Minutes = prevActivityMinutes < 30 && newActivityMinutes >= 30
		let justReached60Minutes = prevActivityMinutes < 60 && newActivityMinutes >= 60
		
		if hour < 17 { // Before 5 PM
			if justReached30Minutes && newActivityMinutes < 60 {
				clearNotification(taskIds: [belowHalfActivity5PMNotificationTaskID], for: dateRange1Day)
				scheduleHalfwayNotifications(schedule: scheduleDaily5PM, newActivityMinutes: newActivityMinutes)
			}
			if justReached60Minutes {
				clearOutdatedNotifications()
				scheduleCompletionNotification(taskId: fullActivity5PMNotificationTaskID, schedule: scheduleDaily5PM)
			}
		} else if hour >= 17 { // After 5 PM
			clearOutdatedNotifications()
			if justReached30Minutes && newActivityMinutes < 60 {
				scheduleNotification(
					taskId: halfActivityImmediateNotificationTaskID,
					title: "Keep going!",
					instructions: "You're halfway there!",
					schedule: scheduleImmediate
				)
			}
			if justReached60Minutes {
				scheduleCompletionNotification(taskId: fullActivityImmediateNotificationTaskID, schedule: scheduleImmediate)
			}
		}
	}
}
