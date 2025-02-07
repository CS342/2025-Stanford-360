//
//  ActivityManagerTest.swift
//  Stanford360Tests
//
//  Created by Elsa Bismuth on 29/01/2025.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT

@testable import Stanford360
import XCTest

final class ActivityManagerTests: XCTestCase {
    var activityManager: ActivityManager?

    override func setUp() {
        super.setUp()
        activityManager = ActivityManager()
    }

    override func tearDown() {
        activityManager = nil
        super.tearDown()
    }

    /// **Test: Logging a new activity**
    func testLogActivityToView() {
        guard let manager = activityManager else {
                XCTFail("Activity Manager not initialized")
                return
        }
        let activity = Activity(
            date: Date(),
            steps: 5000,
            activeMinutes: 50,
            caloriesBurned: 200,
            activityType: "Running"
        )

        manager.logActivityToView(activity)
        XCTAssertEqual(manager.activities.count, 1, "Activity should be logged in the manager.")
        XCTAssertEqual(manager.activities.first?.steps, 5000, "Steps count should be correct.")
    }

    /// **Test: Steps to Active Minutes Conversion**
    func testConvertStepsToMinutes() {
        let minutes = Activity.convertStepsToMinutes(steps: 3000)
        XCTAssertEqual(minutes, 30, "3000 steps should equal 30 active minutes.")
    }

    /// **Test: Streak Calculation**
    func testCheckStreak() {
        let today = Date()
        guard let manager = activityManager else {
                XCTFail("Activity Manager not initialized")
                return
        }
        if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today),
           let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today) {
            let activities = [
                Activity(
                    date: today,
                    steps: 6000,
                    activeMinutes: 60,
                    caloriesBurned: 250,
                    activityType: "Running"
                ),
                Activity(
                    date: yesterday,
                    steps: 7000,
                    activeMinutes: 70,
                    caloriesBurned: 280,
                    activityType: "Cycling"
                ),
                Activity(
                    date: twoDaysAgo,
                    steps: 9000,
                    activeMinutes: 90,
                    caloriesBurned: 220,
                    activityType: "Walking"
                )
            ]
            
            manager.activities = activities
            let streak = manager.checkStreak()

            XCTAssertEqual(streak, 3, "The streak should be 3 days long.")
        }
    }

    /// **Test: Fetch Today's Activity**
    func testGetTodayActivity() {
        let today = Date()
        guard let manager = activityManager else {
                XCTFail("Activity Manager not initialized")
                return
        }
        let activity = Activity(
            date: today,
            steps: 4000,
            activeMinutes: 40,
            caloriesBurned: 180,
            activityType: "Jogging"
        )

        manager.logActivityToView(activity)
        let todayActivity = manager.getTodayActivity()

        XCTAssertNotNil(todayActivity, "Today's activity should be found.")
        XCTAssertEqual(todayActivity?.steps, 4000, "Today's activity steps should be correct.")
    }

    /// **Test: Motivational Message**
    func testTriggerMotivation() {
        guard let manager = activityManager else {
                XCTFail("Activity Manager not initialized")
                return
        }
        let activity = Activity(
            date: Date(),
            steps: 5000,
            activeMinutes: 50,
            caloriesBurned: 200,
            activityType: "Running"
        )
        manager.logActivityToView(activity)

        let message = manager.triggerMotivation()
        XCTAssertTrue(message.contains("Keep going!"), "Message should encourage user to complete 60 minutes.")
    }
}
