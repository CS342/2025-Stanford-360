//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
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
    let milestoneManager = MilestoneManager()

    var hydrationByDate: [Date: [HydrationLog]] {
        var logsByDate: [Date: [HydrationLog]] = [:]
        for log in hydration {
            let normalizedDate = Calendar.current.startOfDay(for: log.timestamp)
            logsByDate[normalizedDate, default: []].append(log)
        }
        return logsByDate
    }
    
    var streak: Int {
        let calendar = Calendar.current
        var streakCount = 0
        var currentDate = calendar.date(byAdding: .day, value: -1, to: Date()) ?? Date()

        let todayIntake = getTotalHydrationOunces(hydrationByDate[calendar.startOfDay(for: Date())] ?? [])
        let isTodayQualified = todayIntake >= 60

        while true {
            let dailyIntake = getTotalHydrationOunces(hydrationByDate[calendar.startOfDay(for: currentDate)] ?? [])

            if dailyIntake >= 60 {
                streakCount += 1
                guard let previousDate = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                    break
                }
                currentDate = previousDate
            } else {
                break
            }
        }

        return isTodayQualified ? streakCount + 1 : streakCount
    }
    
    init(hydration: [HydrationLog] = []) {
        self.hydration = hydration
    }

    func getTodayTotalOunces() -> Double {
        let today = Calendar.current.startOfDay(for: Date())
        return hydrationByDate[today]?.reduce(0) { $0 + $1.hydrationOunces } ?? 0
    }
    
    func getTotalHydrationOunces(_ logs: [HydrationLog]) -> Double {
        logs.reduce(0) { $0 + $1.hydrationOunces }
    }
	
	func reverseSortHydrationByDate(_ hydration: [HydrationLog]) -> [HydrationLog] {
		hydration.sorted { $0.timestamp > $1.timestamp }
	}
    
    func getLatestMilestone() -> Double {
        let totalIntake = getTodayTotalOunces()
        return milestoneManager.getLatestMilestone(total: totalIntake)
    }
    
    func recallLastIntake() {
        let today = Calendar.current.startOfDay(for: Date())

        if let lastLogIndex = hydration.lastIndex(where: {
            Calendar.current.startOfDay(for: $0.timestamp) == today
        }) {
            hydration.remove(at: lastLogIndex)
        }
    }
}
