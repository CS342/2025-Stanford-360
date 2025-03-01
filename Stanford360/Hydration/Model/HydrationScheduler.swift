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
final class HydrationScheduler: Module, DefaultInitializable, EnvironmentAccessible {
    @Dependency(Scheduler.self) @ObservationIgnored private var scheduler

    @MainActor var viewState: ViewState = .idle

    init() {}

    func configure() {
        do {
            try scheduler.createOrUpdateTask(
                id: "hydration-reminder",
                title: "💧 Stay Hydrated!",
                instructions: "You haven't logged any water intake in the last 4 hours. Drink up!",
                category: Task.Category(rawValue: "Hydration"),
                schedule: .daily(hour: 9, minute: 0, startingAt: .today), // First reminder at 9 AM
                scheduleNotifications: true
            )
        } catch {
            viewState = .error(AnyLocalizedError(error: error, defaultErrorDescription: "Failed to create hydration reminder."))
        }
    }

    // MARK: - Called when the user logs water intake to reschedule reminders.
    @MainActor
    func userLoggedWaterIntake() async {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        
        // If it's after 9 PM, don't schedule new reminders
        if hour >= 21 {
            print("⏳ Skipping hydration reminder after 9 PM.")
            return
        }

        // If it's before 9 AM, also skip scheduling
        if hour < 9 {
            print("⏳ Skipping hydration reminder before 9 AM.")
            return
        }
        
        // Schedule a new reminder
        do {
            try scheduler.createOrUpdateTask(
                id: "hydration-reminder",
                title: "💧 Stay Hydrated!",
                instructions: "You haven't logged any water intake in the last 4 hours. Drink up!",
                category: Task.Category(rawValue: "Hydration"),
                schedule: .daily(
                    hour: Calendar.current.component(.hour, from: now) + 4,
                    minute: Calendar.current.component(.minute, from: now),
                    startingAt: .now
                ),
                scheduleNotifications: true
            )
        } catch {
        }
    }
}
