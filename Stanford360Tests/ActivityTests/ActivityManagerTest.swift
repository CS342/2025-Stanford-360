//
//  ActivityManagerTest.swift
//  Stanford360Tests
//
//  Created by Elsa Bismuth on 29/01/2025.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT

import Foundation
@testable import Stanford360
import SwiftUICore
import Testing

struct ActivityManagerTests {
    /// **Test: Logging a new activity**
    @Test
    func testLogActivity() {
        let activityManager = ActivityManager()
        
        let activity = Activity(date: Date(), steps: 5000, activeMinutes: 50, activityType: "Running")
        activityManager.activities.append(activity)

        #expect(activityManager.activities.count == 1, "Activity should be logged in the manager.")
        #expect(activityManager.activities.first?.steps == 5000, "Steps count should be correct.")
    }

    /// **Test: Get Today's Total Minutes**
    @Test
    func testGetTodayTotalMinutes() {
        let activityManager = ActivityManager()
        
        let today = Date()
        // Use optional binding instead of force unwrapping
        guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today) else {
            #expect(Bool(false), "Failed to create yesterday date")
            return
        }
            
        let activities = [
            Activity(date: today, steps: 3000, activeMinutes: 30, activityType: "Running"),
            Activity(date: today, steps: 4000, activeMinutes: 45, activityType: "Walking"),
            Activity(date: yesterday, steps: 5000, activeMinutes: 50, activityType: "Cycling")
        ]

        activityManager.activities = activities
        let totalMinutes = activityManager.getTodayTotalMinutes()

        #expect(totalMinutes == 75, "Today's total minutes should be 75.")
    }

    /// **Test: Trigger Motivation**
    @Test
    func testTriggerMotivation() {
        let activityManager = ActivityManager()
        
        let activities = [
            Activity(date: Date(), steps: 3000, activeMinutes: 30, activityType: "Running"),
            Activity(date: Date(), steps: 2500, activeMinutes: 25, activityType: "Walking")
        ]

        activityManager.activities = activities

        // Test when total active minutes are less than 60
        let motivationMessage = activityManager.triggerMotivation()
        #expect(motivationMessage.contains("Keep going!"), "Message should encourage user to complete 60 minutes.")

        // Add enough minutes to meet the goal
        activityManager.activities.append(Activity(date: Date(), steps: 6000, activeMinutes: 60, activityType: "Cycling"))
        let motivationMessageAfterGoal = activityManager.triggerMotivation()
        #expect(motivationMessageAfterGoal.contains("Amazing!"), "Message should congratulate user for reaching the daily goal.")
    }

    /// **Test: Streak Calculation**
    @Test
    func testCheckStreak() {
        let activityManager = ActivityManager()
        
        let today = Date()
        let calendar = Calendar.current
        
        // Use optional binding for date calculations
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
              let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today) else {
            #expect(Bool(false), "Failed to create date objects")
            return
        }

        let activities = [
            Activity(date: today, steps: 6000, activeMinutes: 60, activityType: "Running"),
            Activity(date: yesterday, steps: 7000, activeMinutes: 70, activityType: "Cycling"),
            Activity(date: twoDaysAgo, steps: 9000, activeMinutes: 90, activityType: "Walking")
        ]

        activityManager.activities = activities
        let streak = activityManager.streak

        #expect(streak == 3, "The streak should be 3 days long.")
    }

    /// **Test: Streak Calculation - Broken Streak**
    @Test
    func testCheckStreakWithBreak() {
        let activityManager = ActivityManager()
        
        let today = Date()
        let calendar = Calendar.current
        
        // Use optional binding for date calculations
        guard let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: today),
              let fiveDaysAgo = calendar.date(byAdding: .day, value: -5, to: today) else {
            #expect(Bool(false), "Failed to create date objects")
            return
        }

        let activities = [
            Activity(date: today, steps: 8000, activeMinutes: 80, activityType: "Running"),
            Activity(date: threeDaysAgo, steps: 7000, activeMinutes: 70, activityType: "Cycling"),
            Activity(date: fiveDaysAgo, steps: 10000, activeMinutes: 100, activityType: "Swimming")
        ]

        activityManager.activities = activities
        let streak = activityManager.streak

        #expect(streak == 1, "The streak should reset because of the 2-day gap.")
    }

    /// **Test: No Activity for Today**
    @Test
    func testGetNoTodayActivity() {
        let activityManager = ActivityManager()
        
        let todayMinutes = activityManager.getTodayTotalMinutes()

        #expect(todayMinutes == 0, "There should be no activity for today.")
    }
    
    /// **Test: Activities By Date**
    @Test
    func testActivitiesByDate() {
        let activityManager = ActivityManager()
        
        let today = Date()
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: today)
        
        // Use optional binding instead of force unwrapping
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else {
            #expect(Bool(false), "Failed to create yesterday date")
            return
        }
        
        let yesterdayStart = calendar.startOfDay(for: yesterday)
        
        let activities = [
            Activity(date: today, steps: 3000, activeMinutes: 30, activityType: "Running"),
            Activity(date: today, steps: 4000, activeMinutes: 45, activityType: "Walking"),
            Activity(date: yesterday, steps: 5000, activeMinutes: 50, activityType: "Cycling")
        ]
        
        activityManager.activities = activities
        let activitiesByDate = activityManager.activitiesByDate
        
        #expect(activitiesByDate.count == 2, "Activities should be grouped into 2 days")
        #expect(activitiesByDate[todayStart]?.count == 2, "Today should have 2 activities")
        #expect(activitiesByDate[yesterdayStart]?.count == 1, "Yesterday should have 1 activity")
    }
    
//    /// **Test: Reverse Sort Activities By Date**
//    @Test
//    func testReverseSortActivitiesByDate() {
//        let activityManager = ActivityManager()
//        
//        let today = Date()
//        let calendar = Calendar.current
//        
//        // Use optional binding for date calculations
//        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
//              let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today) else {
//            #expect(Bool(false), "Failed to create date objects")
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
//        #expect(sortedActivities.count == 3, "Should contain all activities")
//        #expect(sortedActivities[0].date == today, "First activity should be today's")
//        #expect(sortedActivities[1].date == yesterday, "Second activity should be yesterday's")
//        #expect(sortedActivities[2].date == twoDaysAgo, "Third activity should be from two days ago")
//    }
//    
    /// **Test: Get Latest Milestone**
    @Test
    func testGetLatestMilestone() {
        let activityManager = ActivityManager()
        
        let today = Date()
        
        // Test with different minute values
        let testCases = [
            (minutes: 0, expected: 0.0),
            (minutes: 30, expected: 20),
            (minutes: 60, expected: 60),
            (minutes: 90, expected: 80)
        ]
        
        for testCase in testCases {
            activityManager.activities = [
                Activity(date: today, steps: 3000, activeMinutes: testCase.minutes, activityType: "Running")
            ]
            
            let milestone = activityManager.getLatestMilestone()
            #expect(milestone == testCase.expected, "Milestone should be \(testCase.expected) for \(testCase.minutes) minutes")
        }
    }
    
    /// **Test: Trigger Motivation with No Activity**
    @Test
    func testTriggerMotivationWithNoActivity() {
        let activityManager = ActivityManager()
        
        // Clear any activities
        activityManager.activities = []
        
        let motivationMessage = activityManager.triggerMotivation()
        #expect(motivationMessage.contains("Start your activity"), "Should encourage to start activity when no minutes logged")
    }
    
    /// **Test: Custom ActivityManager Initialization**
    @Test
    func testCustomInitialization() {
        let today = Date()
        let activities = [
            Activity(date: today, steps: 3000, activeMinutes: 30, activityType: "Running"),
            Activity(date: today, steps: 4000, activeMinutes: 45, activityType: "Walking")
        ]
        
        // Initialize with custom activities
        let customActivityManager = ActivityManager(activities: activities)
        
        #expect(customActivityManager.activities.count == 2, "Should have 2 activities")
        #expect(customActivityManager.getTodayTotalMinutes() == 75, "Total minutes should be 75")
    }
    
    /// **Test: Streak with Insufficient Activity Minutes**
    @Test
    func testStreakWithInsufficientActivityMinutes() {
        let activityManager = ActivityManager()
        
        let today = Date()
        let calendar = Calendar.current
        
        // Use optional binding for date calculation
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else {
            #expect(Bool(false), "Failed to create yesterday date")
            return
        }
        
        let activities = [
            Activity(date: today, steps: 6000, activeMinutes: 60, activityType: "Running"),
            Activity(date: yesterday, steps: 3000, activeMinutes: 30, activityType: "Walking") // Less than 60 minutes
        ]
        
        activityManager.activities = activities
        let streak = activityManager.streak
        
        #expect(streak == 1, "Streak should be 1 since yesterday didn't have enough minutes")
    }
}
