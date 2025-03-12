//
//  ActivityManagerComprehensiveTests.swift
//  Stanford360
//
//  Created by Elsa Bismuth on 11/03/2025.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT

import Foundation
@testable import Stanford360
import SwiftUICore
import Testing

struct ActivityManagerComprehensiveTests {
    // Helper to create dates with specific times
    func createDate(day: Int, month: Int, year: Int, hour: Int = 10, minute: Int = 0) -> Date {
        var components = DateComponents()
        components.day = day
        components.month = month
        components.year = year
        components.hour = hour
        components.minute = minute
        
        return Calendar.current.date(from: components) ?? Date()
    }
    
    // MARK: - Detailed closure tests
    
    @Test
    func testImplicitClosureInStreakGetter() {
        let activityManager = ActivityManager()
        
        // Create activities that will specifically test the closure in the streak getter
        let today = Date()
        let calendar = Calendar.current
        
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
              let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today) else {
            #expect(Bool(false), "Failed to create test dates")
            return
        }
        
        // Add activities with varying minutes to test the specific condition in the closure
        activityManager.activities = [
            Activity(date: today, steps: 5500, activeMinutes: 55, activityType: "Running"),
            Activity(date: today, steps: 500, activeMinutes: 5, activityType: "Walking"),
            Activity(date: yesterday, steps: 6100, activeMinutes: 61, activityType: "Cycling"),
            Activity(date: twoDaysAgo, steps: 5900, activeMinutes: 59, activityType: "Swimming")
        ]
        
        // This will execute the implicit closure in the streak getter
        let currentStreak = activityManager.streak
        
        // Verify the streak calculation is correct based on the 60 minute threshold
        #expect(currentStreak == 2, "Streak should be 2 with today and yesterday having sufficient minutes")
        
        // Test boundary conditions
        activityManager.activities = [
            Activity(date: today, steps: 6000, activeMinutes: 60, activityType: "Running"), // Exactly 60 minutes
            Activity(date: yesterday, steps: 5900, activeMinutes: 59, activityType: "Cycling") // Just under threshold
        ]
        
        #expect(activityManager.streak == 1, "Streak should be 1 with today having exactly 60 minutes and yesterday under threshold")
    }
    
    @Test
    func testClosuresInGetTodayTotalMinutes() {
        let activityManager = ActivityManager()
        
        // Create activities for today with different times
        let today = Date()
        
        // Create activities at different times today to test the filter closure
        guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today),
              let morningToday = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: today),
              let afternoonToday = Calendar.current.date(bySettingHour: 14, minute: 30, second: 0, of: today),
              let eveningToday = Calendar.current.date(bySettingHour: 19, minute: 45, second: 0, of: today) else {
            #expect(Bool(false), "Failed to create test dates")
            return
        }
        
        // Activities that should be counted for today
        activityManager.activities = [
            Activity(date: morningToday, steps: 1000, activeMinutes: 10, activityType: "Running"),
            Activity(date: afternoonToday, steps: 2000, activeMinutes: 20, activityType: "Walking"),
            Activity(date: eveningToday, steps: 3000, activeMinutes: 30, activityType: "Cycling"),
            // Activity from yesterday that should NOT be counted
            Activity(date: yesterday, steps: 4000, activeMinutes: 40, activityType: "Swimming")
        ]
        
        // This will execute both closures in getTodayTotalMinutes
        let todayMinutes = activityManager.getTodayTotalMinutes()
        
        #expect(todayMinutes == 60, "Today's total minutes should be 60 (10+20+30)")
        
        // Edge case: no activities today
        activityManager.activities = [
            Activity(date: yesterday, steps: 4000, activeMinutes: 40, activityType: "Swimming")
        ]
        
        #expect(activityManager.getTodayTotalMinutes() == 0, "Today's total minutes should be 0 with no activities today")
        
        // Edge case: empty activities array
        activityManager.activities = []
        #expect(activityManager.getTodayTotalMinutes() == 0, "Today's total minutes should be 0 with empty activities")
    }
    
    @Test
    func testClosureInGetTotalActivityMinutes() {
        let activityManager = ActivityManager()
        
        // Create activities with varying minutes
        let activities = [
            Activity(date: Date(), steps: 100, activeMinutes: 1, activityType: "Walking"),
            Activity(date: Date(), steps: 200, activeMinutes: 2, activityType: "Running"),
            Activity(date: Date(), steps: 300, activeMinutes: 3, activityType: "Cycling")
        ]
        
        // This will execute the closure in getTotalActivityMinutes
        let totalMinutes = activityManager.getTotalActivityMinutes(activities)
        
        #expect(totalMinutes == 6, "Total activity minutes should be 6 (1+2+3)")
        
        // Test with activities having zero minutes
        let zeroActivities = [
            Activity(date: Date(), steps: 0, activeMinutes: 0, activityType: "Walking"),
            Activity(date: Date(), steps: 100, activeMinutes: 1, activityType: "Running"),
            Activity(date: Date(), steps: 0, activeMinutes: 0, activityType: "Cycling")
        ]
        
        #expect(activityManager.getTotalActivityMinutes(zeroActivities) == 1,
               "Total minutes should be 1 with some zero minute activities")
    }
    
    @Test
    func testGetLatestMilestone() {
        let activityManager = ActivityManager()
        
        // Set up different activity totals and test milestone calculations
        
        // Test case 1: 0 minutes
        activityManager.activities = []
        let milestone0 = activityManager.getLatestMilestone()
        #expect(milestone0 == 0, "Milestone should be 0 for 0 minutes")
        
        // Test case 2: 30 minutes (0.5 milestone)
        activityManager.activities = [
            Activity(date: Date(), steps: 3000, activeMinutes: 30, activityType: "Walking")
        ]
        let milestone30 = activityManager.getLatestMilestone()
        #expect(milestone30 == 20, "Milestone should be 20 for 30 minutes")
        
        // Test case 3: 60 minutes (1.0 milestone)
        activityManager.activities = [
            Activity(date: Date(), steps: 6000, activeMinutes: 60, activityType: "Running")
        ]
        let milestone60 = activityManager.getLatestMilestone()
        #expect(milestone60 == 60, "Milestone should be 60 for 60 minutes")
        
        // Test case 4: 90 minutes (1.5 milestone)
        activityManager.activities = [
            Activity(date: Date(), steps: 9000, activeMinutes: 90, activityType: "Cycling")
        ]
        let milestone90 = activityManager.getLatestMilestone()
        #expect(milestone90 == 80, "Milestone should be 80 for 90 minutes")
        
        // Test case 5: 120 minutes (2.0 milestone)
        activityManager.activities = [
            Activity(date: Date(), steps: 12000, activeMinutes: 120, activityType: "Swimming")
        ]
        let milestone120 = activityManager.getLatestMilestone()
        #expect(milestone120 == 120, "Milestone should be 120 for 120 minutes")
    }
    
    @Test
    func testTriggerMotivationAllBranches() {
        let activityManager = ActivityManager()
        
        // Test case 1: No activities (0 minutes)
        activityManager.activities = []
        let message0 = activityManager.triggerMotivation()
        #expect(message0.contains("Start your activity today"), "Message should encourage starting activity")
        
        // Test case 2: Some activity but less than 60 minutes
        activityManager.activities = [
            Activity(date: Date(), steps: 3000, activeMinutes: 30, activityType: "Walking")
        ]
        let message30 = activityManager.triggerMotivation()
        #expect(message30.contains("Keep going!"), "Message should encourage continuing activity")
        #expect(message30.contains("30"), "Message should mention remaining minutes")
        
        // Test case 3: Exactly 60 minutes
        activityManager.activities = [
            Activity(date: Date(), steps: 6000, activeMinutes: 60, activityType: "Running")
        ]
        let message60 = activityManager.triggerMotivation()
        #expect(message60.contains("Amazing!"), "Message should congratulate for reaching goal")
        
        // Test case 4: More than 60 minutes
        activityManager.activities = [
            Activity(date: Date(), steps: 9000, activeMinutes: 90, activityType: "Cycling")
        ]
        let message90 = activityManager.triggerMotivation()
        #expect(message90.contains("Amazing!"), "Message should congratulate for exceeding goal")
    }
    
    // MARK: - Additional comprehensive tests
    
    @Test
    func testMultipleDayActivityPatterns() {
        let activityManager = ActivityManager()
        
        // Create a complex pattern of activities across several days
        let today = Date()
        let calendar = Calendar.current
        
        var dates: [Date] = []
        for int in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -int, to: today) {
                dates.append(date)
            }
        }
        
        // Ensure we have enough dates
        guard dates.count >= 7 else {
            #expect(Bool(false), "Failed to create test dates")
            return
        }
        
        // Create a complex pattern:
        // Today: 65 minutes (above threshold)
        // Yesterday: 45 minutes (below threshold)
        // 2 days ago: 70 minutes (above threshold)
        // 3 days ago: 80 minutes (above threshold)
        // 4 days ago: No activity
        // 5 days ago: 90 minutes (above threshold)
        // 6 days ago: 100 minutes (above threshold)
        activityManager.activities = [
            // Today
            Activity(date: dates[0], steps: 4000, activeMinutes: 40, activityType: "Running"),
            Activity(date: dates[0], steps: 2500, activeMinutes: 25, activityType: "Walking"),
            
            // Yesterday
            Activity(date: dates[1], steps: 4500, activeMinutes: 45, activityType: "Cycling"),
            
            // 2 days ago
            Activity(date: dates[2], steps: 7000, activeMinutes: 70, activityType: "Swimming"),
            
            // 3 days ago
            Activity(date: dates[3], steps: 8000, activeMinutes: 80, activityType: "Dancing"),
            
            // 4 days ago - No activity
            
            // 5 days ago
            Activity(date: dates[5], steps: 9000, activeMinutes: 90, activityType: "Sports"),
            
            // 6 days ago
            Activity(date: dates[6], steps: 10000, activeMinutes: 100, activityType: "PE")
        ]
        
        // Test streak calculation
        let streak = activityManager.streak
        #expect(streak == 1, "Streak should be 1 because yesterday was below threshold")
        
        // Test activitiesByDate
        let activitiesByDate = activityManager.activitiesByDate
        #expect(activitiesByDate.count == 6, "Should have activities for 6 days")
        
        // Check counts for each day
        let todayStart = calendar.startOfDay(for: dates[0])
        let yesterdayStart = calendar.startOfDay(for: dates[1])
        
        #expect(activitiesByDate[todayStart]?.count == 2, "Today should have 2 activities")
        #expect(activitiesByDate[yesterdayStart]?.count == 1, "Yesterday should have 1 activity")
    }
    
    @Test
    func testReverseSortWithIdenticalDates() {
        let activityManager = ActivityManager()
        
        // Create activities with identical dates but different properties
        let now = Date()
        
        let activities = [
            Activity(date: now, steps: 1000, activeMinutes: 10, activityType: "Walking"),
            Activity(date: now, steps: 2000, activeMinutes: 20, activityType: "Running"),
            Activity(date: now, steps: 3000, activeMinutes: 30, activityType: "Cycling")
        ]
        
        // Test sorting
        let sorted = activityManager.reverseSortActivitiesByDate(activities)
        
        #expect(sorted.count == 3, "Should contain all activities")
        
        // Since dates are identical, the original order should be preserved
        #expect(sorted[0].activeMinutes == 10, "First activity should have 10 minutes")
        #expect(sorted[1].activeMinutes == 20, "Second activity should have 20 minutes")
        #expect(sorted[2].activeMinutes == 30, "Third activity should have 30 minutes")
    }
    
    @Test
    func testActivitiesByDateEdgeCases() {
        let activityManager = ActivityManager()
        
        // Test with empty activities
        activityManager.activities = []
        let emptyResult = activityManager.activitiesByDate
        #expect(emptyResult.isEmpty, "Result should be empty for empty activities")
        
        // Test with activities at different times on the same day
        let today = Date()
        let calendar = Calendar.current
        
        guard let morning = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: today),
              let evening = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: today) else {
            #expect(Bool(false), "Failed to create test time-of-day dates")
            return
        }
        
        activityManager.activities = [
            Activity(date: morning, steps: 1000, activeMinutes: 10, activityType: "Walking"),
            Activity(date: evening, steps: 2000, activeMinutes: 20, activityType: "Running")
        ]
        
        let sameDayResult = activityManager.activitiesByDate
        let todayStart = calendar.startOfDay(for: today)
        
        #expect(sameDayResult.count == 1, "Should have activities for 1 day")
        #expect(sameDayResult[todayStart]?.count == 2, "Should have 2 activities for today")
    }
    
    @Test
    func testGetTodayTotalMinutesEdgeCases() {
        let activityManager = ActivityManager()
        
        // Test with activities at midnight
        let calendar = Calendar.current
        let today = Date()
        
        // Create a date that's exactly midnight today
        let midnight = calendar.startOfDay(for: today)
        
        activityManager.activities = [
            Activity(date: midnight, steps: 1000, activeMinutes: 10, activityType: "Walking")
        ]
        
        let midnightMinutes = activityManager.getTodayTotalMinutes()
        #expect(midnightMinutes == 10, "Should count activity at midnight")
        
        // Test with activities at 23:59:59 today
        var components = calendar.dateComponents([.year, .month, .day], from: today)
        components.hour = 23
        components.minute = 59
        components.second = 59
        
        guard let endOfDay = calendar.date(from: components) else {
            #expect(Bool(false), "Failed to create end of day date")
            return
        }
        
        activityManager.activities = [
            Activity(date: endOfDay, steps: 2000, activeMinutes: 20, activityType: "Running")
        ]
        
        let endOfDayMinutes = activityManager.getTodayTotalMinutes()
        #expect(endOfDayMinutes == 20, "Should count activity at end of day")
    }
}
