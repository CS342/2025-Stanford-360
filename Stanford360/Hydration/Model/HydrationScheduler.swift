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
                schedule: .daily(hour: 7, minute: 0, startingAt: .today), // First reminder at 7 AM
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

            let currentHour = calendar.component(.hour, from: now)
            
            if currentHour >= 21 {
                print("⏳ Skipping hydration reminder after 9 PM.")
                return
            }
            if currentHour < 3 {
                print("⏳ Skipping hydration reminder before 3 AM.")
                return
            }

            guard let reminderDate = calendar.date(byAdding: .hour, value: 4, to: now) else {
                print("❌ Failed to calculate reminder date")
                return
            }
            
            let reminderHour = calendar.component(.hour, from: reminderDate)
            let reminderMinute = calendar.component(.minute, from: reminderDate)

            do {
                try scheduler.createOrUpdateTask(
                    id: "hydration-reminder",
                    title: "💧 Stay Hydrated!",
                    instructions: "You haven't logged any water intake in the last 4 hours. Drink up!",
                    category: Task.Category(rawValue: "Hydration"),
                    schedule: .daily(
                        hour: reminderHour,
                        minute: reminderMinute,
                        startingAt: reminderDate
                    ),
                    scheduleNotifications: true
                )
            } catch {
                print("❌ Error scheduling reminder: \(error)")
            }
        }
}
