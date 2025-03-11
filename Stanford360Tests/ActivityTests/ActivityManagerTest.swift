//
//  ActivityManagerTest.swift
//  Stanford360Tests
//
//  Created by Elsa Bismuth on 29/01/2025.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT

import FirebaseFirestore
import Foundation
@testable import Stanford360
import SwiftUICore
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
    func testLogActivity() {
        guard let activityManager = activityManager else {
            XCTFail("ActivityManager should not be nil")
            return
        }
        
        let activity = Activity(date: Date(), steps: 5000, activeMinutes: 50, activityType: "Running")
        activityManager.activities.append(activity)

        XCTAssertEqual(activityManager.activities.count, 1, "Activity should be logged in the manager.")
        XCTAssertEqual(activityManager.activities.first?.steps, 5000, "Steps count should be correct.")
    }
//
//    /// **Test: Get Today's Total Minutes**
//    func testGetTodayTotalMinutes() {
//        guard let activityManager = activityManager else {
//            XCTFail("ActivityManager should not be nil")
//            return
//        }
//        
//        let today = Date()
//        // Use optional binding instead of force unwrapping
//        if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today) {
//            let activities = [
//                Activity(date: today, steps: 3000, activeMinutes: 30, activityType: "Running"),
//                Activity(date: today, steps: 4000, activeMinutes: 45, activityType: "Walking"),
//                Activity(date: yesterday, steps: 5000, activeMinutes: 50, activityType: "Cycling")
//            ]
//
//            activityManager.activities = activities
//            let totalMinutes = activityManager.getTodayTotalMinutes()
//
//            XCTAssertEqual(totalMinutes, 75, "Today's total minutes should be 75.")
//        } else {
//            XCTFail("Failed to create yesterday date")
//        }
//    }
//
//    /// **Test: Get Total Activity Minutes**
//    func testGetTotalActivityMinutes() {
//        guard let activityManager = activityManager else {
//            XCTFail("ActivityManager should not be nil")
//            return
//        }
//        
//        let activities = [
//            Activity(date: Date(), steps: 3000, activeMinutes: 30, activityType: "Running"),
//            Activity(date: Date(), steps: 4000, activeMinutes: 45, activityType: "Walking"),
//            Activity(date: Date(), steps: 5000, activeMinutes: 50, activityType: "Cycling")
//        ]
//
//        let totalMinutes = activityManager.getTotalActivityMinutes(activities)
//
//        XCTAssertEqual(totalMinutes, 125, "Total activity minutes should be 125.")
//    }
//    
//    /// **Test: Trigger Motivation**
//    func testTriggerMotivation() {
//        guard let activityManager = activityManager else {
//            XCTFail("ActivityManager should not be nil")
//            return
//        }
//        
//        let activities = [
//            Activity(date: Date(), steps: 3000, activeMinutes: 30, activityType: "Running"),
//            Activity(date: Date(), steps: 4000, activeMinutes: 45, activityType: "Walking")
//        ]
//
//        activityManager.activities = activities
//
//        // Test when total active minutes are less than 60
//        let motivationMessage = activityManager.triggerMotivation()
//        XCTAssertTrue(motivationMessage.contains("Keep going!"), "Message should encourage user to complete 60 minutes.")
//
//        // Add enough minutes to meet the goal
//        activityManager.activities.append(Activity(date: Date(), steps: 5000, activeMinutes: 60, activityType: "Cycling"))
//        let motivationMessageAfterGoal = activityManager.triggerMotivation()
//        XCTAssertTrue(motivationMessageAfterGoal.contains("Amazing!"), "Message should congratulate user for reaching the daily goal.")
//    }
//
//    /// **Test: Streak Calculation**
//    func testCheckStreak() {
//        guard let activityManager = activityManager else {
//            XCTFail("ActivityManager should not be nil")
//            return
//        }
//        
//        let today = Date()
//        let calendar = Calendar.current
//        
//        // Use optional binding for date calculations
//        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
//              let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today) else {
//            XCTFail("Failed to create date objects")
//            return
//        }
//
//        let activities = [
//            Activity(date: today, steps: 6000, activeMinutes: 60, activityType: "Running"),
//            Activity(date: yesterday, steps: 7000, activeMinutes: 70, activityType: "Cycling"),
//            Activity(date: twoDaysAgo, steps: 9000, activeMinutes: 90, activityType: "Walking")
//        ]
//
//        activityManager.activities = activities
//        let streak = activityManager.streak
//
//        XCTAssertEqual(streak, 3, "The streak should be 3 days long.")
//    }
//
//    /// **Test: Streak Calculation - Broken Streak**
//    func testCheckStreakWithBreak() {
//        guard let activityManager = activityManager else {
//            XCTFail("ActivityManager should not be nil")
//            return
//        }
//        
//        let today = Date()
//        let calendar = Calendar.current
//        
//        // Use optional binding for date calculations
//        guard let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: today),
//              let fiveDaysAgo = calendar.date(byAdding: .day, value: -5, to: today) else {
//            XCTFail("Failed to create date objects")
//            return
//        }
//
//        let activities = [
//            Activity(date: today, steps: 8000, activeMinutes: 80, activityType: "Running"),
//            Activity(date: threeDaysAgo, steps: 7000, activeMinutes: 70, activityType: "Cycling"),
//            Activity(date: fiveDaysAgo, steps: 10000, activeMinutes: 100, activityType: "Swimming")
//        ]
//
//        activityManager.activities = activities
//        let streak = activityManager.streak
//
//        XCTAssertEqual(streak, 1, "The streak should reset because of the 2-day gap.")
//    }
//
//    /// **Test: No Activity for Today**
//    func testGetNoTodayActivity() {
//        guard let activityManager = activityManager else {
//            XCTFail("ActivityManager should not be nil")
//            return
//        }
//        
//        let todayMinutes = activityManager.getTodayTotalMinutes()
//
//        XCTAssertEqual(todayMinutes, 0, "There should be no activity for today.")
//    }
//    
//    /// **Test: Activities By Date**
//    func testActivitiesByDate() {
//        guard let activityManager = activityManager else {
//            XCTFail("ActivityManager should not be nil")
//            return
//        }
//        
//        let today = Date()
//        let calendar = Calendar.current
//        let todayStart = calendar.startOfDay(for: today)
//        
//        // Use optional binding instead of force unwrapping
//        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else {
//            XCTFail("Failed to create yesterday date")
//            return
//        }
//        
//        let yesterdayStart = calendar.startOfDay(for: yesterday)
//        
//        let activities = [
//            Activity(date: today, steps: 3000, activeMinutes: 30, activityType: "Running"),
//            Activity(date: today, steps: 4000, activeMinutes: 45, activityType: "Walking"),
//            Activity(date: yesterday, steps: 5000, activeMinutes: 50, activityType: "Cycling")
//        ]
//        
//        activityManager.activities = activities
//        let activitiesByDate = activityManager.activitiesByDate
//        
//        XCTAssertEqual(activitiesByDate.count, 2, "Activities should be grouped into 2 days")
//        XCTAssertEqual(activitiesByDate[todayStart]?.count, 2, "Today should have 2 activities")
//        XCTAssertEqual(activitiesByDate[yesterdayStart]?.count, 1, "Yesterday should have 1 activity")
//    }
//    
//    /// **Test: Reverse Sort Activities By Date**
//    func testReverseSortActivitiesByDate() {
//        guard let activityManager = activityManager else {
//            XCTFail("ActivityManager should not be nil")
//            return
//        }
//        
//        let today = Date()
//        let calendar = Calendar.current
//        
//        // Use optional binding for date calculations
//        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
//              let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today) else {
//            XCTFail("Failed to create date objects")
//            return
//        }
//        
//        let activities = [
//            Activity(date: yesterday, steps: 5000, activeMinutes: 50, activityType: "Cycling"),
//            Activity(date: today, steps: 3000, activeMinutes: 30, activityType: "Running"),
//            Activity(date: twoDaysAgo, steps: 4000, activeMinutes: 45, activityType: "Walking")
//        ]
//        
//        let sortedActivities = activityManager.reverseSortActivitiesByDate(activities)
//        
//        XCTAssertEqual(sortedActivities.count, 3, "Should contain all activities")
//        XCTAssertEqual(sortedActivities[0].date, today, "First activity should be today's")
//        XCTAssertEqual(sortedActivities[1].date, yesterday, "Second activity should be yesterday's")
//        XCTAssertEqual(sortedActivities[2].date, twoDaysAgo, "Third activity should be from two days ago")
//    }
//    
//    /// **Test: Get Latest Milestone**
//    func testGetLatestMilestone() {
//        guard let activityManager = activityManager else {
//            XCTFail("ActivityManager should not be nil")
//            return
//        }
//        
//        let today = Date()
//        
//        // Test with different minute values
//        let testCases = [
//            (minutes: 0, expected: 0.0),
//            (minutes: 30, expected: 0.5),
//            (minutes: 60, expected: 1.0),
//            (minutes: 90, expected: 1.5)
//        ]
//        
//        for testCase in testCases {
//            activityManager.activities = [
//                Activity(date: today, steps: 3000, activeMinutes: testCase.minutes, activityType: "Running")
//            ]
//            
//            let milestone = activityManager.getLatestMilestone()
//            XCTAssertEqual(milestone, testCase.expected, "Milestone should be \(testCase.expected) for \(testCase.minutes) minutes")
//        }
//    }
//    
//    /// **Test: Trigger Motivation with No Activity**
//    func testTriggerMotivationWithNoActivity() {
//        guard let activityManager = activityManager else {
//            XCTFail("ActivityManager should not be nil")
//            return
//        }
//        
//        // Clear any activities
//        activityManager.activities = []
//        
//        let motivationMessage = activityManager.triggerMotivation()
//        XCTAssertTrue(motivationMessage.contains("Start your activity"), "Should encourage to start activity when no minutes logged")
//    }
//    
//    /// **Test: Save To Storage Success**
//    func testSaveToStorage() {
//        guard let activityManager = activityManager else {
//            XCTFail("ActivityManager should not be nil")
//            return
//        }
//        
//        let today = Date()
//        let activities = [
//            Activity(date: today, steps: 3000, activeMinutes: 30, activityType: "Running"),
//            Activity(date: today, steps: 4000, activeMinutes: 45, activityType: "Walking")
//        ]
//        
//        activityManager.activities = activities
//        
//        // Test that the method doesn't throw an exception
//        XCTAssertNoThrow(activityManager.saveToStorage(), "Saving activities should not throw")
//        
//        // Verify data was saved to UserDefaults
//        let savedData = UserDefaults.standard.data(forKey: "activities")
//        XCTAssertNotNil(savedData, "Data should be saved to UserDefaults")
//        
//        // Clean up after test
//        UserDefaults.standard.removeObject(forKey: "activities")
//    }
//    
//    /// **Test: Custom ActivityManager Initialization**
//    func testCustomInitialization() {
//        let today = Date()
//        let activities = [
//            Activity(date: today, steps: 3000, activeMinutes: 30, activityType: "Running"),
//            Activity(date: today, steps: 4000, activeMinutes: 45, activityType: "Walking")
//        ]
//        
//        // Initialize with custom activities
//        let customActivityManager = ActivityManager(activities: activities)
//        
//        XCTAssertEqual(customActivityManager.activities.count, 2, "Should have 2 activities")
//        XCTAssertEqual(customActivityManager.getTodayTotalMinutes(), 75, "Total minutes should be 75")
//    }
//    
//    /// **Test: Streak with Insufficient Activity Minutes**
//    func testStreakWithInsufficientActivityMinutes() {
//        guard let activityManager = activityManager else {
//            XCTFail("ActivityManager should not be nil")
//            return
//        }
//        
//        let today = Date()
//        let calendar = Calendar.current
//        
//        // Use optional binding for date calculation
//        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else {
//            XCTFail("Failed to create yesterday date")
//            return
//        }
//        
//        let activities = [
//            Activity(date: today, steps: 6000, activeMinutes: 60, activityType: "Running"),
//            Activity(date: yesterday, steps: 3000, activeMinutes: 30, activityType: "Walking") // Less than 60 minutes
//        ]
//        
//        activityManager.activities = activities
//        let streak = activityManager.streak
//        
//        XCTAssertEqual(streak, 1, "Streak should be 1 since yesterday didn't have enough minutes")
//    }
}
