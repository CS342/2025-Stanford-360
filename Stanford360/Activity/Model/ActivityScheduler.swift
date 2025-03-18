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

extension Stanford360Scheduler {
	@MainActor
	func configureActivityScheduler() {
		// Schedules a notification every day at 5 PM encouraging the user to complete their 60 minutes of activity
		do {
			try scheduler.createOrUpdateTask(
				id: belowHalfActivity5PMNotificationTaskID,
				title: "🏃 Let's get moving!",
				instructions: "Don't forget your 60 minutes of daily activity!",
				schedule: .daily(hour: 17, minute: 0, startingAt: .today),
				scheduleNotifications: true
			)
		} catch {
			viewState = .error(AnyLocalizedError(error: error, defaultErrorDescription: "Failed to create or update scheduled tasks."))
		}
	}
	
	// periphery:ignore
	/// "delete" notification occurence of belowHalfActivity5PMNotificationTaskID by marking it complete such that it doesn't fire
	@MainActor
	func deleteNotificationOccurence(taskIds: [String]) {
		do {
			let events = try scheduler.queryEvents(
				for: dateRange1Day,
				predicate: #Predicate { taskIds.contains($0.id) }
			)
			
			for event in events {
				event.complete()
			}
		} catch {
			viewState = .error(AnyLocalizedError(error: error, defaultErrorDescription: "Failed to retrieve scheduled event."))
		}
	}
	
	// periphery:ignore
	@MainActor
	func handleOnLoggedBefore5PM(_ surpassed30Minutes: Bool, _ surpassed60Minutes: Bool) {
		if surpassed30Minutes || surpassed60Minutes {
			deleteNotificationOccurence(taskIds: [belowHalfActivity5PMNotificationTaskID])
		}
		
		guard let five5PM = Calendar.current.date(from: DateComponents(hour: 17, minute: 0)) else {
			return
		}
		
		// schedule notification occurence of halfActivity5PMNotificationTaskID
		if surpassed30Minutes {
			do {
				try scheduler.createOrUpdateTask(
					id: halfActivity5PMNotificationTaskID,
					title: "🏃 Keep Going!",
					instructions: "You're halfway to your 60 minute activity goal!",
					schedule: .once(at: five5PM),
					scheduleNotifications: true
				)
			} catch {
				viewState = .error(AnyLocalizedError(error: error, defaultErrorDescription: "Failed to create or update scheduled tasks."))
			}
		}
		
		// schedule notification occurence of fullActivity5PMNotificationTaskID
		if surpassed60Minutes {
			do {
				try scheduler.createOrUpdateTask(
					id: fullActivity5PMNotificationTaskID,
					title: "🎉 Congrats!",
					instructions: "You've completed 60 minutes of activity!",
					schedule: .once(at: five5PM),
					scheduleNotifications: true
				)
			} catch {
				viewState = .error(AnyLocalizedError(error: error, defaultErrorDescription: "Failed to create or update scheduled tasks."))
			}
		}
	}
	
	// periphery:ignore
	@MainActor
	func handleOnLoggedAtOrAfter5PM(_ surpassed30Minutes: Bool, _ surpassed60Minutes: Bool) {
		let potentialEventIDs = [
			belowHalfActivity5PMNotificationTaskID,
			halfActivity5PMNotificationTaskID,
			fullActivity5PMNotificationTaskID
		]
		
		deleteNotificationOccurence(taskIds: potentialEventIDs)
		
		// schedule notification occurence of halfActivity5PMNotificationTaskID
		if surpassed30Minutes {
			do {
				try scheduler.createOrUpdateTask(
					id: halfActivityImmediateNotificationTaskID,
					title: "🏃 Keep Going!",
					instructions: "You're halfway to your 60 minute activity goal!",
					schedule: .once(at: Calendar.current.date(byAdding: .second, value: 1, to: .now) ?? Date()),
					scheduleNotifications: true
				)
			} catch {
				viewState = .error(AnyLocalizedError(error: error, defaultErrorDescription: "Failed to create or update scheduled tasks."))
			}
		}
		
		// schedule notification occurence of fullActivity5PMNotificationTaskID
		if surpassed60Minutes {
			do {
				try scheduler.createOrUpdateTask(
					id: fullActivityImmediateNotificationTaskID,
					title: "🎉 Congrats!",
					instructions: "You've completed 60 minutes of activity!",
					schedule: .once(at: Calendar.current.date(byAdding: .second, value: 1, to: .now) ?? Date()),
					scheduleNotifications: true
				)
			} catch {
				viewState = .error(AnyLocalizedError(error: error, defaultErrorDescription: "Failed to create or update scheduled tasks."))
			}
		}
	}
	
	// periphery:ignore
	@MainActor
	func handleNotificationsOnLoggedActivity(prevActivityMinutes: Int, newActivityMinutes: Int) async {
		let now = Date()
		let calendar = Calendar.current
		let hour = calendar.component(.hour, from: now)
		
		let surpassed30Minutes = prevActivityMinutes < 30 && newActivityMinutes >= 30
		let surpassed60Minutes = prevActivityMinutes < 60 && newActivityMinutes >= 60
		
		if hour < 17 { // Before 5 PM
			handleOnLoggedBefore5PM(surpassed30Minutes, surpassed60Minutes)
		} else { // On or after 5 PM
			handleOnLoggedAtOrAfter5PM(surpassed30Minutes, surpassed60Minutes)
		}
	}
}
