//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import SwiftUI

extension Stanford360Standard {
    func storeHydrationLog(_ hydrationLog: HydrationLog) async {
        guard let logID = hydrationLog.id else {
            print("❌ Hydration Log ID is nil.")
            return
        }
        
        do {
            let docRef = try await configuration.userDocumentReference
            try await docRef.collection("hydrationLogs").document(logID).setData(from: hydrationLog)
        } catch {
            print("❌ Error writing hydration log to Firestore: \(error)")
        }
    }
    
    func fetchHydrationLogs() async -> [HydrationLog] {
        var hydrationLogs: [HydrationLog] = []
        
        do {
            let docRef = try await configuration.userDocumentReference
            let logsSnapshot = try await docRef.collection("hydrationLogs").getDocuments()
            
            hydrationLogs = try logsSnapshot.documents.compactMap { doc in
                try doc.data(as: HydrationLog.self)
            }
        } catch {
            print("❌ Error fetching hydration logs from Firestore: \(error)")
        }
        
        return hydrationLogs
    }
    
    @MainActor
    func fetchWeeklyHydrationData() async -> [DailyHydrationData] {
        do {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())

            let weekday = calendar.component(.weekday, from: today)
            let daysSinceSunday = weekday - 1
            guard let sunday = calendar.date(byAdding: .day, value: -daysSinceSunday, to: today) else {
                print("❌ Failed to calculate start of the week (Sunday)")
                return []
            }

            var hydrationMap: [String: Double] = [:]
            let weekDaysOrder = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

            for dayName in weekDaysOrder {
                hydrationMap[dayName] = 0.0
            }

            let hydrationLogs = await fetchHydrationLogs()

            for log in hydrationLogs {
                let logDate = calendar.startOfDay(for: log.timestamp)
                if logDate >= sunday, logDate <= today {
                    let dayName = weekDaysOrder[calendar.component(.weekday, from: logDate) - 1]
                    hydrationMap[dayName, default: 0.0] += log.hydrationOunces
                }
            }

            let weeklyData = weekDaysOrder.map { day in
                DailyHydrationData(dayName: day, intakeOz: hydrationMap[day] ?? 0.0)
            }

            return weeklyData
        }
    }

    @MainActor
    func fetchMonthlyHydrationData() async -> [DailyHydrationData] {
        do {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())

            guard let monthRange = calendar.range(of: .day, in: .month, for: today) else {
                print("❌ Failed to retrieve month range")
                return []
            }
            let totalDaysInMonth = monthRange.count

            var dailyData: [String: Double] = [:]

            let hydrationLogs = await fetchHydrationLogs()

            for log in hydrationLogs {
                let logDate = calendar.startOfDay(for: log.timestamp)
                let dayString = String(format: "%02d", calendar.component(.day, from: logDate))

                if calendar.isDate(logDate, equalTo: today, toGranularity: .month) {
                    dailyData[dayString, default: 0.0] += log.hydrationOunces
                }
            }

            let monthData = (1...totalDaysInMonth).map { day -> DailyHydrationData in
                let dayString = String(format: "%02d", day)
                return DailyHydrationData(dayName: dayString, intakeOz: dailyData[dayString] ?? 0.0)
            }

            return monthData
        }
    }
}
