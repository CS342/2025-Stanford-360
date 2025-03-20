//
//  ActivityManagerTests.swift
//  Stanford360Tests
//
//  Created by Test Author on 19/03/2025.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT

import Foundation
@testable import Stanford360
import Testing

@Suite("ActivityManager Tests")
struct ActivityManagerTests {
    @Test("Initialize with empty activities")
    func testInitWithEmptyActivities() throws {
        let manager = ActivityManager()
        #expect(manager.activities.isEmpty)
        #expect(manager.activitiesByDate.isEmpty)
    }
    
    @Test("Initialize with activities")
    func testInitWithActivities() throws {
        let activities = [
            Activity(
                date: Date(),
                steps: 3000,
                activeMinutes: 30,
                activityType: "Running"
            )
        ]
        let manager = ActivityManager(activities: activities)
        #expect(manager.activities.count == 1)
    }
    
    @Test("Activities grouped by date")
    func testActivitiesByDate() throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterdayDate = calendar.date(byAdding: .day, value: -1, to: today)
        guard let yesterday = yesterdayDate else {
            return // Skip test if date creation fails
        }
        
        let activities = [
            Activity(
                date: today,
                steps: 2000,
                activeMinutes: 30,
                activityType: "Walking"
            ),
            Activity(
                date: today,
                steps: 4000,
                activeMinutes: 40,
                activityType: "Cycling"
            ),
            Activity(
                date: yesterday,
                steps: 5000,
                activeMinutes: 50,
                activityType: "Swimming"
            )
        ]
        
        let manager = ActivityManager(activities: activities)
        let activitiesByDate = manager.activitiesByDate
        
        #expect(activitiesByDate.count == 2)
        #expect(activitiesByDate[today]?.count == 2)
        #expect(activitiesByDate[yesterday]?.count == 1)
    }
    
    @Test("Reverse sort activities by date")
    func testReverseSortActivitiesByDate() throws {
        let calendar = Calendar.current
        let today = Date()
        let yesterdayDate = calendar.date(byAdding: .day, value: -1, to: today)
        let twoDaysAgoDate = calendar.date(byAdding: .day, value: -2, to: today)
        
        guard let yesterday = yesterdayDate, let twoDaysAgo = twoDaysAgoDate else {
            return // Skip test if date creation fails
        }
        
        let activities = [
            Activity(
                date: yesterday,
                steps: 3000,
                activeMinutes: 30,
                activityType: "Walking"
            ),
            Activity(
                date: today,
                steps: 4000,
                activeMinutes: 40,
                activityType: "Running"
            ),
            Activity(
                date: twoDaysAgo,
                steps: 5000,
                activeMinutes: 50,
                activityType: "Swimming"
            )
        ]
        
        let manager = ActivityManager(activities: activities)
        let sorted = manager.reverseSortActivitiesByDate(activities)
        
        #expect(sorted[0].date > sorted[1].date)
        #expect(sorted[1].date > sorted[2].date)
    }
    
    @Test("Get today total minutes")
    func testGetTodayTotalMinutes() throws {
        let calendar = Calendar.current
        let today = Date()
        let yesterdayDate = calendar.date(byAdding: .day, value: -1, to: today)
        guard let yesterday = yesterdayDate else {
            return // Skip test if date creation fails
        }
        
        let activities = [
            Activity(
                date: today,
                steps: 2000,
                activeMinutes: 25,
                activityType: "Walking"
            ),
            Activity(
                date: today,
                steps: 3000,
                activeMinutes: 35,
                activityType: "Running"
            ),
            Activity(
                date: yesterday,
                steps: 4000,
                activeMinutes: 45,
                activityType: "Sports"
            )
        ]
        
        let manager = ActivityManager(activities: activities)
        #expect(manager.getTodayTotalMinutes() == 60)
    }
    
    @Test("Get total activity minutes")
    func testGetTotalActivityMinutes() throws {
        let activities = [
            Activity(
                date: Date(),
                steps: 2000,
                activeMinutes: 20,
                activityType: "Walking"
            ),
            Activity(
                date: Date(),
                steps: 3000,
                activeMinutes: 30,
                activityType: "Running"
            ),
            Activity(
                date: Date(),
                steps: 4000,
                activeMinutes: 40,
                activityType: "Sports"
            )
        ]
        
        let manager = ActivityManager()
        #expect(manager.getTotalActivityMinutes(activities) == 90)
    }
    
    @Test("Get latest milestone")
    func testGetLatestMilestone() throws {
        let today = Date()
        let activities = [
            Activity(
                date: today,
                steps: 2000,
                activeMinutes: 25,
                activityType: "Walking"
            ),
            Activity(
                date: today,
                steps: 3000,
                activeMinutes: 35,
                activityType: "Running"
            )
        ]
        
        let manager = ActivityManager(activities: activities)
        #expect(manager.getLatestMilestone() == 60)
    }
    
    @Test("Get steps from minutes")
    func testGetStepsFromMinutes() throws {
        let manager = ActivityManager()
        #expect(manager.getStepsFromMinutes(10) == 1000)
        #expect(manager.getStepsFromMinutes(30) == 3000)
        #expect(manager.getStepsFromMinutes(60) == 6000)
    }
    
    @Test("Streak calculation")
    func testStreakCalculation() throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Create dates safely
        let yesterdayDate = calendar.date(byAdding: .day, value: -1, to: today)
        let twoDaysAgoDate = calendar.date(byAdding: .day, value: -2, to: today)
        let fiveDaysAgoDate = calendar.date(byAdding: .day, value: -5, to: today)
        
        guard let yesterday = yesterdayDate,
              let twoDaysAgo = twoDaysAgoDate,
              let fiveDaysAgo = fiveDaysAgoDate else {
            return // Skip test if date creation fails
        }
        
        let activities = [
            // Today: 70 minutes (qualified)
            Activity(
                date: today,
                steps: 3000,
                activeMinutes: 30,
                activityType: "Walking"
            ),
            Activity(
                date: today,
                steps: 4000,
                activeMinutes: 40,
                activityType: "Running"
            ),
            
            // Yesterday: 65 minutes (qualified)
            Activity(
                date: yesterday,
                steps: 6500,
                activeMinutes: 65,
                activityType: "Cycling"
            ),
            
            // Two days ago: 50 minutes (qualified)
            Activity(
                date: twoDaysAgo,
                steps: 5000,
                activeMinutes: 50,
                activityType: "Swimming"
            ),
            
            // Five days ago: 80 minutes (qualified but streak broken)
            Activity(
                date: fiveDaysAgo,
                steps: 8000,
                activeMinutes: 80,
                activityType: "Running"
            )
        ]
        
        let manager = ActivityManager(activities: activities)
        #expect(manager.streak == 2)
    }
    
    @Test("Streak calculation with no activities")
    func testStreakCalculationWithNoActivities() throws {
        let manager = ActivityManager(activities: [])
        #expect(manager.streak == 0)
    }
}
