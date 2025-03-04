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

    init() {}

    func configure() {
        do {
            try scheduler.createOrUpdateTask(
                id: "activity-reminder",
                title: "🏃 Keep Moving!",
                instructions: "You haven't logged any activity in the last 5 hours. Time to get moving!",
                category: Task.Category(rawValue: "Activity"),
                schedule: .daily(hour: 9, minute: 0, startingAt: .today), // First reminder at 9 AM
                scheduleNotifications: true
            )
        } catch {
            viewState = .error(AnyLocalizedError(error: error, defaultErrorDescription: "Failed to create activity reminder."))
        }
    }

    @MainActor
    func userLoggedActivity(activityMinutes: Int) async {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)

        // If it's after 9 PM, don't schedule new reminders
        if hour >= 21 {
            print("⏳ Skipping activity reminder after 9 PM.")
            return
        }

        let remainingMinutes = max(0, 60 - activityMinutes)

        if remainingMinutes > 0 {
            // Schedule a new reminder
            do {
                try scheduler.createOrUpdateTask(
                    id: "activity-reminder",
                    title: "🏃 Keep Moving!",
                    instructions: "You have \(remainingMinutes) minutes left to reach your goal of 60 minutes!",
                    category: Task.Category(rawValue: "Activity"),
                    schedule: .daily(
                        hour: Calendar.current.component(.hour, from: now) + 4,
                        minute: Calendar.current.component(.minute, from: now),
                        startingAt: .now
                    ),
                    scheduleNotifications: true
                )
            } catch {
                print("Failed to schedule activity reminder: \(error.localizedDescription)")
            }
        }
    }
}
