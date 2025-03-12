//
//  ActivityManagerStreakTests.swift
//  Stanford360
//
//  Created by Elsa Bismuth on 11/03/2025.
////
//  ActivityManagerStreakTests.swift
//  Stanford360Tests
//
//  Created on 11/03/2025.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT

import Foundation
@testable import Stanford360
import SwiftUICore
import Testing

struct ActivityManagerStreakTests {
    // Helper to create dates
    func createDate(daysAgo: Int, hour: Int = 12, minute: Int = 0) -> Date {
        let calendar = Calendar.current
        guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()),
              let result = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: date) else {
            fatalError("Failed to create test date")
        }
        return result
    }
    
    @Test
    func testStreakCalculationDirectCalls() {
        // This test focuses specifically on the streak getter's implementation
        let activityManager = ActivityManager()
        
        // Empty activities should result in zero streak
        #expect(activityManager.streak == 0, "Streak should be 0 with no activities")
        
        // Add activities for multiple consecutive days
        activityManager.activities = [
            // Today with exactly 60 minutes (threshold)
            Activity(date: createDate(daysAgo: 0), steps: 6000, activeMinutes: 60, activityType: "Running")
        ]
        
        // This should trigger the while loop in streak getter to run once
        #expect(activityManager.streak == 1, "Streak should be 1 with today's activity meeting threshold")
        
        // Add activities for yesterday that don't meet threshold
        activityManager.activities.append(
            Activity(date: createDate(daysAgo: 1), steps: 5000, activeMinutes: 50, activityType: "Walking")
        )
        
        // This should cause the streak calculation to stop at today
        #expect(activityManager.streak == 1, "Streak should still be 1 with yesterday not meeting threshold")
        
        // Now add more to yesterday to make it meet threshold
        activityManager.activities.append(
            Activity(date: createDate(daysAgo: 1), steps: 1000, activeMinutes: 10, activityType: "Walking")
        )
        
        // This should increase the streak
        #expect(activityManager.streak == 2, "Streak should be 2 with today and yesterday meeting threshold")
    }
    
    @Test
    func testStreakMultipleDays() {
        let activityManager = ActivityManager()
        
        // Create 5 days of activities, all meeting the threshold
        for int in 0..<5 {
            activityManager.activities.append(
                Activity(date: createDate(daysAgo: int), steps: 6000, activeMinutes: 60, activityType: "Running")
            )
        }
        
        // Should have a 5-day streak
        #expect(activityManager.streak == 5, "Should have a 5-day streak")
        
        // Add a day with insufficient activity, breaking the streak
        activityManager.activities.append(
            Activity(date: createDate(daysAgo: 5), steps: 5000, activeMinutes: 50, activityType: "Walking")
        )
        
        // Still should be a 5-day streak because day 6 is insufficient
        #expect(activityManager.streak == 5, "Should still have a 5-day streak")
        
        // Add another activity to make day 6 sufficient
        activityManager.activities.append(
            Activity(date: createDate(daysAgo: 5), steps: 1000, activeMinutes: 10, activityType: "Jogging")
        )
        
        // Now we should have a 6-day streak
        #expect(activityManager.streak == 6, "Should have a 6-day streak")
    }
    
    @Test
    func testStreakWithGaps() {
        let activityManager = ActivityManager()
        
        // Create activities with a gap in the middle
        activityManager.activities = [
            // Today
            Activity(date: createDate(daysAgo: 0), steps: 6000, activeMinutes: 60, activityType: "Running"),
            // Yesterday
            Activity(date: createDate(daysAgo: 1), steps: 6000, activeMinutes: 60, activityType: "Cycling"),
            // Skip 2 days ago
            // 3 days ago
            Activity(date: createDate(daysAgo: 3), steps: 6000, activeMinutes: 60, activityType: "Swimming")
        ]
        
        // Should only count today and yesterday (2 days)
        #expect(activityManager.streak == 2, "Streak should be 2 due to gap at 2 days ago")
        
        // Add activity for 2 days ago but insufficient
        activityManager.activities.append(
            Activity(date: createDate(daysAgo: 2), steps: 4500, activeMinutes: 45, activityType: "Walking")
        )
        
        // Should still only count today and yesterday (2 days) because 2 days ago is insufficient
        #expect(activityManager.streak == 2, "Streak should still be 2 with insufficient activity 2 days ago")
        
        // Add more activity for 2 days ago to make it sufficient
        activityManager.activities.append(
            Activity(date: createDate(daysAgo: 2), steps: 1500, activeMinutes: 15, activityType: "Jogging")
        )
        
        // Now should count today, yesterday, and 2 days ago, and 3 days ago (4 days total)
        #expect(activityManager.streak == 4, "Streak should be 4 with sufficient activity all 4 days")
    }
    
    @Test
    func testStreakWithMultipleActivitiesPerDay() {
        let activityManager = ActivityManager()
        
        // Add multiple activities on same day across multiple days
        activityManager.activities = [
            // Today - multiple activities totaling over threshold
            Activity(date: createDate(daysAgo: 0, hour: 9), steps: 2000, activeMinutes: 20, activityType: "Running"),
            Activity(date: createDate(daysAgo: 0, hour: 12), steps: 3000, activeMinutes: 30, activityType: "Walking"),
            Activity(date: createDate(daysAgo: 0, hour: 18), steps: 1000, activeMinutes: 10, activityType: "Cycling"),
            
            // Yesterday - multiple activities totaling exactly threshold
            Activity(date: createDate(daysAgo: 1, hour: 8), steps: 2000, activeMinutes: 20, activityType: "Yoga"),
            Activity(date: createDate(daysAgo: 1, hour: 17), steps: 4000, activeMinutes: 40, activityType: "Swimming"),
            
            // 2 days ago - multiple activities totaling under threshold
            Activity(date: createDate(daysAgo: 2, hour: 10), steps: 2000, activeMinutes: 20, activityType: "Tennis"),
            Activity(date: createDate(daysAgo: 2, hour: 14), steps: 3000, activeMinutes: 30, activityType: "Basketball"),
            
            // 3 days ago - single activity over threshold
            Activity(date: createDate(daysAgo: 3, hour: 16), steps: 7000, activeMinutes: 70, activityType: "Hiking")
        ]
        
        // Should have a 2-day streak (today and yesterday) because 2 days ago is under threshold
        #expect(activityManager.streak == 2, "Streak should be 2 with today and yesterday meeting threshold")
        
        // Add more activity to 2 days ago to make it meet threshold
        activityManager.activities.append(
            Activity(date: createDate(daysAgo: 2, hour: 20), steps: 1000, activeMinutes: 10, activityType: "Stretching")
        )
        
        // Now should have a 3-day streak
        #expect(activityManager.streak == 4, "Streak should be 4 with 2 days ago now meeting threshold")
    }
    
    @Test
    func testStreakEdgeCases() {
        let activityManager = ActivityManager()
        
        // Edge case 1: Activities at midnight
        activityManager.activities = [
            Activity(date: createDate(daysAgo: 0, hour: 0, minute: 0), steps: 6000, activeMinutes: 60, activityType: "Running"),
            Activity(date: createDate(daysAgo: 1, hour: 0, minute: 0), steps: 6000, activeMinutes: 60, activityType: "Cycling")
        ]
        
        #expect(activityManager.streak == 2, "Streak should be 2 with midnight activities")
        
        // Edge case 2: Activities at 23:59
        activityManager.activities = [
            Activity(date: createDate(daysAgo: 0, hour: 23, minute: 59), steps: 6000, activeMinutes: 60, activityType: "Running"),
            Activity(date: createDate(daysAgo: 1, hour: 23, minute: 59), steps: 6000, activeMinutes: 60, activityType: "Cycling")
        ]
        
        #expect(activityManager.streak == 2, "Streak should be 2 with late night activities")
        
        // Edge case 3: Activities spanning different days
        activityManager.activities = [
            // Today morning and evening
            Activity(date: createDate(daysAgo: 0, hour: 8), steps: 3000, activeMinutes: 30, activityType: "Running"),
            Activity(date: createDate(daysAgo: 0, hour: 20), steps: 3000, activeMinutes: 30, activityType: "Walking"),
            
            // Yesterday morning only (not enough)
            Activity(date: createDate(daysAgo: 1, hour: 9), steps: 5000, activeMinutes: 50, activityType: "Cycling")
        ]
        
        #expect(activityManager.streak == 1, "Streak should be 1 with today sufficient, yesterday insufficient")
    }
}
