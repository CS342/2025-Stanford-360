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
    func rescheduleHydrationNotifications() async {
        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)
        
        // Skip scheduling reminders between 8 AM and 3 PM
        if currentHour >= 8 && currentHour < 15 {
            print("⏳ Skipping immediate reminder, will schedule at 3:30 PM.")
            let secondsUntilReminder = TimeInterval((15 - currentHour) * 3600 + 30 * 60) // 3:30 PM
            let reminderDate = Date().addingTimeInterval(secondsUntilReminder)
            await scheduleHydrationReminder(at: reminderDate)
            return
        }

        // Schedule next reminder after 4 hours if within allowed range
        guard let reminderDate = calendar.date(byAdding: .hour, value: 4, to: now) else {
            return
        }
        
        let reminderHour = calendar.component(.hour, from: reminderDate)
        
        // Cancel any hydration reminder scheduled at midnight or later
        if reminderHour >= 24 {
            await cancelScheduledReminder()
            return
        }

        await scheduleHydrationReminder(at: reminderDate)
    }

    // MARK: - Schedule a Hydration Reminder
    @MainActor
    private func scheduleHydrationReminder(at date: Date) async {
        let calendar = Calendar.current
        let reminderHour = calendar.component(.hour, from: date)
        let reminderMinute = calendar.component(.minute, from: date)

        do {
            try scheduler.createOrUpdateTask(
                id: "hydration-reminder",
                title: "💧 Stay Hydrated!",
                instructions: "It's been a while since you last logged water. Time to hydrate!",
                category: Task.Category(rawValue: "Hydration"),
                schedule: .daily(
                    hour: reminderHour,
                    minute: reminderMinute,
                    startingAt: date
                ),
                scheduleNotifications: true
            )
        } catch {
        }
    }

    // MARK: - Cancel Hydration Reminder
    @MainActor
    private func cancelScheduledReminder() async {
        do {
            try scheduler.deleteTasks(
                try scheduler.queryTasks(
                    for: Date()..<Date().addingTimeInterval(60 * 60 * 24),
                    predicate: #Predicate { $0.id == "hydration-reminder" }
                )
            )
        } catch {
        }
    }
}
