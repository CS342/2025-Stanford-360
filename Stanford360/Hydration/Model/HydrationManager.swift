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
    var hydration: [HydrationLog] = []

    init(hydration: [HydrationLog] = []) {
        self.hydration = hydration
    }

    // MARK: - Get today’s total hydration intake
    func getTodayHydrationOunces() -> Double {
        let today = Calendar.current.startOfDay(for: Date())
        return hydration
            .filter { Calendar.current.isDate($0.lastHydrationDate, inSameDayAs: today) }
            .reduce(0) { $0 + $1.amountOz }
    }

    // MARK: - Get the latest hydration log
    func getLatestLog() -> HydrationLog? {
        hydration.max(by: { $0.lastHydrationDate < $1.lastHydrationDate })
    }

    // MARK: - Calculate the streak
    func calculateStreak(previousStreak: Int) -> (streak: Int, isStreakUpdated: Bool) {
        let todayTotalIntake = getTodayHydrationOunces()
        var newStreak = getLatestLog()?.streak ?? previousStreak
        var isStreakUpdated = getLatestLog()?.isStreakUpdated ?? false

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // If no logs today, use the previous day's streak
        if let lastLog = getLatestLog(), !calendar.isDate(lastLog.lastHydrationDate, inSameDayAs: today) {
            newStreak = previousStreak
            isStreakUpdated = false
        }

        // Update streak if reaching 60 oz and it hasn't already been updated today
        if todayTotalIntake >= 60 && !isStreakUpdated {
            newStreak += 1
            isStreakUpdated = true
        }

        return (newStreak, isStreakUpdated)
    }

    // MARK: - Add new hydration log
    func addHydrationLog(amount: Double, timestamp: Date, previousStreak: Int) {
        let (newStreak, isStreakUpdated) = calculateStreak(previousStreak: previousStreak)

        let newLog = HydrationLog(
            amountOz: amount,
            streak: newStreak,
            lastTriggeredMilestone: max(getTodayHydrationOunces(), amount),
            lastHydrationDate: timestamp,
            isStreakUpdated: isStreakUpdated
        )
        hydration.append(newLog)
    }
}
