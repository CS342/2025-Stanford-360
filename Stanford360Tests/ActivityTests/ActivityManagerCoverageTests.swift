//  ActivityManagerCoverageTests.swift
//  Stanford360Tests
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

struct ActivityManagerCoverageTests {
    // Helper to create dates
    func createDate(day: Int, month: Int, year: Int) -> Date {
        var components = DateComponents()
        components.day = day
        components.month = month
        components.year = year
        components.hour = 10
        components.minute = 0
        
        return Calendar.current.date(from: components) ?? Date()
    }
    
    @Test
    func testActivitiesByDateGetter() {
        // Create activities across multiple dates
        let activityManager = ActivityManager()
        
        // March 1, 2, and 3, 2025
        let day1 = createDate(day: 1, month: 3, year: 2025)
        let day2 = createDate(day: 2, month: 3, year: 2025)
        let day3 = createDate(day: 3, month: 3, year: 2025)
        
        // Create 2 activities for day 1, 1 for day 2, and 3 for day 3
        let activities = [
            Activity(date: day1, steps: 1000, activeMinutes: 10, activityType: "Walking"),
            Activity(date: day1, steps: 2000, activeMinutes: 20, activityType: "Running"),
            Activity(date: day2, steps: 3000, activeMinutes: 30, activityType: "Dancing"),
            Activity(date: day3, steps: 4000, activeMinutes: 40, activityType: "Sports"),
            Activity(date: day3, steps: 5000, activeMinutes: 50, activityType: "PE"),
            Activity(date: day3, steps: 6000, activeMinutes: 60, activityType: "Other")
        ]
        
        activityManager.activities = activities
        
        // Access activitiesByDate to trigger the getter
        let activitiesByDate = activityManager.activitiesByDate
        
        // Verify the grouping is correct
        let day1Start = Calendar.current.startOfDay(for: day1)
        let day2Start = Calendar.current.startOfDay(for: day2)
        let day3Start = Calendar.current.startOfDay(for: day3)
        
        #expect(activitiesByDate.count == 3, "Should have 3 days of activities")
        #expect(activitiesByDate[day1Start]?.count == 2, "Day 1 should have 2 activities")
        #expect(activitiesByDate[day2Start]?.count == 1, "Day 2 should have 1 activity")
        #expect(activitiesByDate[day3Start]?.count == 3, "Day 3 should have 3 activities")
    }
    
    @Test
    func testStreakGetter() {
        let activityManager = ActivityManager()
        
        // Get current date to work with
        let today = Date()
        let calendar = Calendar.current
        
        // Create dates for yesterday and the day before
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
              let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today),
              let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: today),
              let fourDaysAgo = calendar.date(byAdding: .day, value: -4, to: today) else {
            #expect(Bool(false), "Failed to create test dates")
            return
        }
        
        // Test case 1: No activities
        #expect(activityManager.streak == 0, "Streak should be 0 with no activities")
        
        // Test case 2: Today only with sufficient minutes
        activityManager.activities = [
            Activity(date: today, steps: 6000, activeMinutes: 60, activityType: "Running")
        ]
        #expect(activityManager.streak == 1, "Streak should be 1 with only today's activity")
        
        // Test case 3: Today only with insufficient minutes
        activityManager.activities = [
            Activity(date: today, steps: 3000, activeMinutes: 30, activityType: "Walking")
        ]
        #expect(activityManager.streak == 0, "Streak should be 0 with insufficient minutes today")
        
        // Test case 4: Today and yesterday, both sufficient
        activityManager.activities = [
            Activity(date: today, steps: 6000, activeMinutes: 60, activityType: "Running"),
            Activity(date: yesterday, steps: 7000, activeMinutes: 70, activityType: "Cycling")
        ]
        #expect(activityManager.streak == 2, "Streak should be 2 with today and yesterday sufficient")
        
        // Test case 5: Today sufficient, yesterday insufficient
        activityManager.activities = [
            Activity(date: today, steps: 6000, activeMinutes: 60, activityType: "Running"),
            Activity(date: yesterday, steps: 3000, activeMinutes: 30, activityType: "Walking")
        ]
        #expect(activityManager.streak == 1, "Streak should be 1 with today sufficient, yesterday insufficient")
        
        // Test case 6: Several days of sufficient activities
        activityManager.activities = [
            Activity(date: today, steps: 6000, activeMinutes: 60, activityType: "Running"),
            Activity(date: yesterday, steps: 7000, activeMinutes: 70, activityType: "Cycling"),
            Activity(date: twoDaysAgo, steps: 8000, activeMinutes: 80, activityType: "Swimming"),
            Activity(date: threeDaysAgo, steps: 9000, activeMinutes: 90, activityType: "Dancing")
        ]
        #expect(activityManager.streak == 4, "Streak should be 4 with four days of sufficient activities")
        
        // Test case 7: Broken streak (gap in days)
        activityManager.activities = [
            Activity(date: today, steps: 6000, activeMinutes: 60, activityType: "Running"),
            Activity(date: yesterday, steps: 7000, activeMinutes: 70, activityType: "Cycling"),
            // No activity for twoDaysAgo
            Activity(date: threeDaysAgo, steps: 9000, activeMinutes: 90, activityType: "Dancing"),
            Activity(date: fourDaysAgo, steps: 10000, activeMinutes: 100, activityType: "Sports")
        ]
        #expect(activityManager.streak == 2, "Streak should be 2 due to the gap in days")
        
        // Test case 8: Multiple activities in a day summing to sufficient
        activityManager.activities = [
            Activity(date: today, steps: 3000, activeMinutes: 30, activityType: "Walking"),
            Activity(date: today, steps: 3000, activeMinutes: 30, activityType: "Running"),
            Activity(date: yesterday, steps: 7000, activeMinutes: 70, activityType: "Cycling")
        ]
        #expect(activityManager.streak == 2, "Streak should be 2 with combined activities for today")
    }
    
    @Test
    func testReverseSortActivitiesByDate() {
        let activityManager = ActivityManager()
        
        // Create activities with different dates
        let today = Date()
        let calendar = Calendar.current
        
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
              let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today),
              let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: today) else {
            #expect(Bool(false), "Failed to create test dates")
            return
        }
        
        // Create activities in random order
        let activities = [
            Activity(date: yesterday, steps: 5000, activeMinutes: 50, activityType: "Cycling"),
            Activity(date: threeDaysAgo, steps: 7000, activeMinutes: 70, activityType: "Swimming"),
            Activity(date: today, steps: 3000, activeMinutes: 30, activityType: "Running"),
            Activity(date: twoDaysAgo, steps: 4000, activeMinutes: 45, activityType: "Walking")
        ]
        
        // Call the method to sort activities
        let sortedActivities = activityManager.reverseSortActivitiesByDate(activities)
        
        // Verify the sorting
        #expect(sortedActivities.count == 4, "Should contain all activities")
        #expect(sortedActivities[0].date == today, "First activity should be today's")
        #expect(sortedActivities[1].date == yesterday, "Second activity should be yesterday's")
        #expect(sortedActivities[2].date == twoDaysAgo, "Third activity should be from two days ago")
        #expect(sortedActivities[3].date == threeDaysAgo, "Fourth activity should be from three days ago")
        
        // Test with empty array
        let emptyResult = activityManager.reverseSortActivitiesByDate([])
        #expect(emptyResult.isEmpty, "Result should be empty for empty input")
        
        // Test with activities on the same day
        let sameDay = [
            Activity(date: today, steps: 3000, activeMinutes: 30, activityType: "Running"),
            Activity(date: today, steps: 5000, activeMinutes: 50, activityType: "Walking")
        ]
        
        let sameDaySorted = activityManager.reverseSortActivitiesByDate(sameDay)
        #expect(sameDaySorted.count == 2, "Should contain both activities")
        #expect(sameDaySorted[0].date == today && sameDaySorted[1].date == today,
               "Both activities should have today's date")
    }
    
    @Test
    func testGetTotalActivityMinutes() {
        let activityManager = ActivityManager()
        
        // Test case 1: Empty array
        let emptyMinutes = activityManager.getTotalActivityMinutes([])
        #expect(emptyMinutes == 0, "Total minutes should be 0 for empty array")
        
        // Test case 2: Single activity
        let singleActivity = [
            Activity(date: Date(), steps: 3000, activeMinutes: 30, activityType: "Running")
        ]
        
        let singleMinutes = activityManager.getTotalActivityMinutes(singleActivity)
        #expect(singleMinutes == 30, "Total minutes should be 30 for single activity")
        
        // Test case 3: Multiple activities
        let multipleActivities = [
            Activity(date: Date(), steps: 3000, activeMinutes: 30, activityType: "Running"),
            Activity(date: Date(), steps: 4000, activeMinutes: 45, activityType: "Walking"),
            Activity(date: Date(), steps: 5000, activeMinutes: 50, activityType: "Cycling")
        ]
        
        let multipleMinutes = activityManager.getTotalActivityMinutes(multipleActivities)
        #expect(multipleMinutes == 125, "Total minutes should be 125 for multiple activities")
        
        // Test case 4: Activities with zero minutes
        let zeroMinuteActivities = [
            Activity(date: Date(), steps: 0, activeMinutes: 0, activityType: "Running"),
            Activity(date: Date(), steps: 0, activeMinutes: 0, activityType: "Walking")
        ]
        
        let zeroMinutes = activityManager.getTotalActivityMinutes(zeroMinuteActivities)
        #expect(zeroMinutes == 0, "Total minutes should be 0 for activities with zero minutes")
    }
}
