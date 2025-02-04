//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

@testable import Stanford360
import XCTest

final class HydrationTrackerTests: XCTestCase {
    var hydrationTracker = HydrationTracker()
    let defaults = UserDefaults.standard

    override func setUp() {
        super.setUp()
        hydrationTracker = HydrationTracker()
        resetUserDefaults()
    }

    override func tearDown() {
        resetUserDefaults()
        super.tearDown()
    }

    /// Reset UserDefaults to prevent test interference
    private func resetUserDefaults() {
        defaults.removeObject(forKey: "totalIntakeToday")
        defaults.removeObject(forKey: "lastTriggeredMilestone")
        defaults.removeObject(forKey: "hydrationStreak")
        defaults.removeObject(forKey: "lastHydrationDate")
    }

    /// **Test: Loading hydration data**
    func testLoadHydrationData() {
        defaults.set(40.0, forKey: "totalIntakeToday")
        defaults.set(3, forKey: "hydrationStreak")

        hydrationTracker.loadHydrationData()

        XCTAssertEqual(hydrationTracker.totalIntake, 40.0, "Total intake should load correctly.")
        XCTAssertEqual(hydrationTracker.streak, 3, "Streak should load correctly.")
    }

    /// **Test: Logging water intake updates totalIntake correctly**
    func testLogWaterIntake() {
        let expectation = expectation(description: "Water intake logged successfully")

        hydrationTracker.logWaterIntake(intakeAmount: 20.0) { success in
            XCTAssertTrue(success, "LogWaterIntake should succeed for positive input.")
            XCTAssertEqual(self.defaults.double(forKey: "totalIntakeToday"), 20.0, "Total intake should update in UserDefaults.")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    /// **Test: Logging negative intake fails**
    func testInvalidWaterIntake() {
        let expectation = expectation(description: "Invalid water intake should fail")

        hydrationTracker.logWaterIntake(intakeAmount: -10.0) { success in
            XCTAssertFalse(success, "LogWaterIntake should fail for negative input.")
            XCTAssertEqual(self.defaults.double(forKey: "totalIntakeToday"), 0.0, "Total intake should remain unchanged.")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    /// **Test: Milestone notifications trigger at 20oz and 60oz**
    func testMilestoneTriggers() {
        hydrationTracker.logWaterIntake(intakeAmount: 20.0) { _ in }
        let lastTriggered = defaults.double(forKey: "lastTriggeredMilestone")
        XCTAssertEqual(lastTriggered, 20.0, "Milestone should trigger at 20 oz.")

        hydrationTracker.logWaterIntake(intakeAmount: 40.0) { _ in }
        let updatedTriggered = defaults.double(forKey: "lastTriggeredMilestone")
        XCTAssertEqual(updatedTriggered, 60.0, "Milestone should trigger at 60 oz.")
    }

    /// **Test: Streak increases when 60oz goal is met**
    func testStreakIncreases() {
        hydrationTracker.logWaterIntake(intakeAmount: 60.0) { _ in }
        hydrationTracker.updateHydrationStreak()
        let streak = defaults.integer(forKey: "hydrationStreak")
        XCTAssertEqual(streak, 1, "Streak should increase when goal is met.")
    }

    /// **Test: Streak resets when goal is not met**
    func testStreakResets() {
        defaults.set(3, forKey: "hydrationStreak") // Simulate 3-day streak
        defaults.set(Date().addingTimeInterval(-86400), forKey: "lastHydrationDate")

        hydrationTracker.updateHydrationStreak()
        let streak = defaults.integer(forKey: "hydrationStreak")
        XCTAssertEqual(streak, 0, "Streak should reset if goal is not met.")
    }
}
