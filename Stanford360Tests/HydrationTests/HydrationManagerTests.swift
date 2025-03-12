//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

@testable import Stanford360
import XCTest

final class HydrationManagerTests: XCTestCase {
    var hydrationManager: HydrationManager?
    
    override func setUp() {
        super.setUp()
        hydrationManager = HydrationManager()
    }
    
    override func tearDown() {
        hydrationManager = nil
        super.tearDown()
    }

    // Test Adding Hydration Logs
    func testAddingHydrationLogs() {
        guard let hydrationManager else {
            XCTFail("HydrationManager not initialized")
            return
        }
        let log1 = HydrationLog(hydrationOunces: 20, timestamp: Date())
        let log2 = HydrationLog(hydrationOunces: 40, timestamp: Date())

        hydrationManager.hydration.append(log1)
        hydrationManager.hydration.append(log2)

        XCTAssertEqual(hydrationManager.hydration.count, 2, "Hydration logs should be correctly added.")
    }
    
    // Test Total Water Intake for Today
    func testGetTodayTotalOunces() {
        guard let hydrationManager else {
            XCTFail("HydrationManager not initialized")
            return
        }
        let today = Date()
        let log1 = HydrationLog(hydrationOunces: 20, timestamp: today)
        let log2 = HydrationLog(hydrationOunces: 40, timestamp: today)
        
        hydrationManager.hydration.append(log1)
        hydrationManager.hydration.append(log2)
        
        XCTAssertEqual(hydrationManager.getTodayTotalOunces(), 60, "Total water intake should be 60 oz.")
    }

    // Test Streak Calculation
    func testStreakCalculation() {
        guard let hydrationManager else {
            XCTFail("HydrationManager not initialized")
            return
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
              let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today) else {
            XCTFail("Failed to compute past dates.")
            return
        }

        hydrationManager.hydration = [
            HydrationLog(hydrationOunces: 30, timestamp: today),
            HydrationLog(hydrationOunces: 60, timestamp: yesterday),
            HydrationLog(hydrationOunces: 60, timestamp: twoDaysAgo)
        ]
        
        XCTAssertEqual(hydrationManager.streak, 2, "Streak should be 2 as the third day is below 60 oz.")
    }
    
    func testStreakResetsOnSkippedDays() {
        guard let hydrationManager else {
            XCTFail("HydrationManager not initialized")
            return
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        guard let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today) else {
            XCTFail("Failed to compute past dates.")
            return
        }

        hydrationManager.hydration = [
            HydrationLog(hydrationOunces: 60, timestamp: today),
            HydrationLog(hydrationOunces: 60, timestamp: twoDaysAgo) // Skipped yesterday
        ]
        
        XCTAssertEqual(hydrationManager.streak, 1, "Streak should reset due to a skipped day.")
    }
    
    // Test Latest Milestone Calculation
    func testGetLatestMilestone() {
        guard let hydrationManager else {
            XCTFail("HydrationManager not initialized")
            return
        }
        let log1 = HydrationLog(hydrationOunces: 35, timestamp: Date())
        let log2 = HydrationLog(hydrationOunces: 10, timestamp: Date())
        
        hydrationManager.hydration.append(log1)
        hydrationManager.hydration.append(log2)
        
        XCTAssertEqual(hydrationManager.getLatestMilestone(), 40, "Latest milestone should be 40 oz.")
    }

    // Test Recalling Last Intake
    func testRecallLastIntake() {
        guard let hydrationManager else {
            XCTFail("HydrationManager not initialized")
            return
        }
        let log1 = HydrationLog(hydrationOunces: 20, timestamp: Date())
        let log2 = HydrationLog(hydrationOunces: 10, timestamp: Date())
        
        hydrationManager.hydration.append(log1)
        hydrationManager.hydration.append(log2)
        
        hydrationManager.recallLastIntake()
        
        XCTAssertEqual(hydrationManager.hydration.count, 1, "Should remove the last intake of today.")
        XCTAssertEqual(hydrationManager.hydration.first?.hydrationOunces, 20, "Only the last log should be removed.")
    }

    // Test Recalling Intake When No Logs Exist
    func testRecallLastIntakeWhenNoLogsExist() {
        guard let hydrationManager else {
            XCTFail("HydrationManager not initialized")
            return
        }
        hydrationManager.recallLastIntake()
        XCTAssertEqual(hydrationManager.hydration.count, 0, "Should not crash when recalling from an empty list.")
    }
}
