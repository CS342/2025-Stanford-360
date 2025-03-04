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
    /// Store hydration document under hydrationLog
    private func hydrationDocument(date: Date) async throws -> DocumentReference {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        return try await configuration.userDocumentReference
            .collection("hydrationLogs")
            .document(dateString)
    }
    
    /// Add or Update Hydration Log
    func addOrUpdateHydrationLog(hydrationLog: HydrationLog) async {
        do {
            let currentDate = Date()

            let hydrationDocRef = try await hydrationDocument(date: currentDate)

            // Update or create the document
            try await hydrationDocRef.setData(from: hydrationLog, merge: true)
        } catch {
            print("❌ Error updating hydration log: \(error)")
        }
    }
    
    /// Fetches the hydration log for the current date
    @MainActor
    func fetchHydrationLog() async throws -> HydrationLog? {
        do {
            let currentDate = Date()
            let hydrationDocRef = try await hydrationDocument(date: currentDate)
            print("✅ Current's date: \(currentDate)")

            let document = try await hydrationDocRef.getDocument()

            // Check if document exists
            if document.exists, let data = document.data() {
                // Extract each field safely
                let amountOz = data["amountOz"] as? Double ?? 0.0
                let streak = data["streak"] as? Int ?? 0
                let lastTriggeredMilestone = data["lastTriggeredMilestone"] as? Double ?? 0.0
                let lastHydrationDate = (data["lastHydrationDate"] as? Timestamp)?.dateValue() ?? Date()
                let isStreakUpdated = data["isStreakUpdated"] as? Bool ?? false

                return HydrationLog(
                    amountOz: amountOz,
                    streak: streak,
                    lastTriggeredMilestone: lastTriggeredMilestone,
                    lastHydrationDate: lastHydrationDate,
                    isStreakUpdated: isStreakUpdated,
                    id: document.documentID
                )
            } else {
                print("⚠️ No hydration log found for today.")
                return nil
            }
        } catch {
            print("❌ Error fetching hydration log: \(error)")
            return nil
        }
    }
    
    @MainActor
    func fetchYesterdayStreak() async -> Int {
        do {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today
            let hydrationDocRef = try await hydrationDocument(date: yesterday)
            
            let document = try await hydrationDocRef.getDocument()
            
            if document.exists, let data = document.data() {
                let yesterdayStreak = data["streak"] as? Int ?? 0
                let yesterdayIntake = data["amountOz"] as? Double ?? 0.0
                
                return yesterdayIntake >= 60 ? yesterdayStreak : 0
            } else {
                return 0
            }
        } catch {
            return 0
        }
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

            let weekDaysOrder = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            var hydrationMap: [String: Double] = [:]

            for dayName in weekDaysOrder {
                hydrationMap[dayName] = 0.0
            }

            for dayOffset in 0..<7 {
                if let date = calendar.date(byAdding: .day, value: dayOffset, to: sunday), date <= today {
                    let hydrationDocRef = try await hydrationDocument(date: date)
                    let document = try await hydrationDocRef.getDocument()

                    if document.exists, let data = document.data() {
                        let intakeOz = data["amountOz"] as? Double ?? 0.0

                        if let weekdayIndex = calendar.dateComponents([.weekday], from: date).weekday {
                            let correctedDayName = weekDaysOrder[weekdayIndex - 1]  // Sunday = index 0
                            hydrationMap[correctedDayName] = intakeOz
                        }
                    }
                }
            }

            let weeklyData = weekDaysOrder.map { day in
                DailyHydrationData(dayName: day, intakeOz: hydrationMap[day] ?? 0.0)
            }

            return weeklyData
        } catch {
            print("❌ Error fetching weekly hydration data: \(error)")
            return []
        }
    }

    @MainActor
    func fetchMonthlyHydrationData() async -> [DailyHydrationData] {
        do {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())

            // Get the range of days in the current month
            guard let monthRange = calendar.range(of: .day, in: .month, for: today) else {
                print("❌ Failed to retrieve month range")
                return []
            }
            let totalDaysInMonth = monthRange.count

            var dailyData: [String: Double] = [:]
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd"

            for day in 1...totalDaysInMonth { // ✅ Fetch only this month's days
                var components = calendar.dateComponents([.year, .month], from: today)
                components.day = day
                if let date = calendar.date(from: components) {
                    let hydrationDocRef = try await hydrationDocument(date: date)
                    let document = try await hydrationDocRef.getDocument()

                    let dayString = String(format: "%02d", day) // Ensure "01", "02", ..., "31"

                    if document.exists, let data = document.data() {
                        let intakeOz = data["amountOz"] as? Double ?? 0.0
                        dailyData[dayString] = intakeOz
                    } else {
                        dailyData[dayString] = 0.0 // If no data, assume 0 oz intake
                    }
                }
            }

            // Convert dictionary to array of DailyHydrationData
            let monthData = dailyData.map { DailyHydrationData(dayName: $0.key, intakeOz: $0.value) }
            return monthData.sorted {
                if let day1 = Int($0.dayName), let day2 = Int($1.dayName) {
                    return day1 < day2
                }
                return false // Handle unexpected cases gracefully
            }
        } catch {
            print("❌ Error fetching monthly hydration data: \(error)")
            return []
        }
    }
}
