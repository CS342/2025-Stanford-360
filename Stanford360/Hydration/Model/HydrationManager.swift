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

    var hydrationByDate: [Date: [HydrationLog]] {
        var logsByDate: [Date: [HydrationLog]] = [:]
        for log in hydration {
            let normalizedDate = Calendar.current.startOfDay(for: log.timestamp)
            logsByDate[normalizedDate, default: []].append(log)
        }
        return logsByDate
    }
    
    var streak: Int {
        calculateStreak()
    }
    
    // Streak Calculation
    var streak2: Int {
        let calendar = Calendar.current
        var streakCount = 0
        var currentDate = Date()

        while let logsByDate = hydrationByDate[calendar.startOfDay(for: currentDate)] {
            let totalLogs = getTotalHydrationOunces(logsByDate)
            if totalLogs >= 60 {
                streakCount += 1
            } else {
                break // Stop counting if the total minutes are not over 60
            }
            // Move to the previous day
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        }

        return streakCount
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
    
    func getLatestMilestone() -> Double {
        let totalIntake = getTodayTotalOunces()
        return Double((Int(totalIntake) / 20) * 20)
    }
    
    func calculateStreak() -> Int {
        let calendar = Calendar.current
        var streakCount = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        while true {
            let dailyIntake = hydrationByDate[currentDate]?.reduce(0) { $0 + $1.hydrationOunces } ?? 0.0
            
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
        return streakCount
    }
}
