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
        let now = Date()
        let todayStart = calendar.startOfDay(for: now)
        
        // Safely calculate yesterday
        guard let previousDate = calendar.date(byAdding: .day, value: -1, to: todayStart) else {
            return 0 // error
        }
        var dateToCheck = previousDate
        
        // Calculate streak for previous days
        var streakCount = 0
        while let logs = hydrationByDate[dateToCheck] {
            let ounces = getTotalHydrationOunces(logs)
            if ounces >= 60 {
                streakCount += 1
            } else {
                break
            }
            guard let newDate = calendar.date(byAdding: .day, value: -1, to: dateToCheck) else {
                return 0 // error
            }
            dateToCheck = newDate
        }
        
        // Handle today's activity separately
        if let todaysLogs = hydrationByDate[todayStart],
           getTotalHydrationOunces(todaysLogs) >= 60 {
            streakCount += 1
        }
        
        return streakCount
    }
    
    init(hydration: [HydrationLog] = []) {
        self.hydration = hydration
    }
    
    func getTodayHydrationOunces() -> Double {
        let today = Calendar.current.startOfDay(for: Date())
        return hydrationByDate[today]?.reduce(0) { $0 + $1.hydrationOunces } ?? 0
    }
    
    func getTotalHydrationOunces(_ logs: [HydrationLog]) -> Double {
        logs.reduce(0) { $0 + $1.hydrationOunces }
    }
    
    func addHydrationLog(amount: Double, timestamp: Date = Date()) {
        let newLog = HydrationLog(hydrationOunces: amount, timestamp: timestamp)
        hydration.append(newLog)
    }
    
    func getLatestMilestone() -> Double {
        let totalIntake = getTodayHydrationOunces()
        return Double((Int(totalIntake) / 20) * 20)
    }
    
    func calculateStreak() -> Int {
        let calendar = Calendar.current
        var streakCount = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        while true {
            let dailyIntake = hydrationByDate[currentDate]?.reduce(0) { $0 + $1.hydrationOunces } ?? 0.0
            print("Date: \(currentDate) -> Daily Intake: \(dailyIntake)")
            
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
        print("Computed streak: \(streakCount)")
        return streakCount
    }
}
