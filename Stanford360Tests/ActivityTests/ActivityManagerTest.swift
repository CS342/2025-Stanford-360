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
// @testable import Stanford360
import SwiftUICore
import XCTest

final class ActivityManagerTests: XCTestCase {
//    var activityManager: ActivityManager?
////    var mockFirestore: Firestore!
////    var mockUserDocRef: DocumentReference!
////    @Environment(Stanford360Standard.self) private var standard
//
//    override func setUp() {
//        super.setUp()
//        activityManager = ActivityManager()
//        
//        // Initialize a mock Firestore instance for testing
////        mockFirestore = Firestore.firestore()
////        mockUserDocRef = mockFirestore.collection("users").document("testUser")
////        
////        // Directly override the `userDocumentReference` method using a testable extension
////        standard.configuration.userDocumentReference = {
////            return self.mockUserDocRef
////        }
//    }
//
//    override func tearDown() {
//        activityManager = nil
////        mockFirestore = nil
////        mockUserDocRef = nil
//        super.tearDown()
//    }
//
//    /// **Test: Logging a new activity**
//    func testLogActivityToView() {
//        guard let manager = activityManager else {
//                XCTFail("Activity Manager not initialized")
//                return
//        }
//        let activity = Activity(
//            date: Date(),
//            steps: 5000,
//            activeMinutes: 50,
//            activityType: "Running"
//        )
//
//        manager.logActivityToView(activity)
//        XCTAssertEqual(manager.activities.count, 1, "Activity should be logged in the manager.")
//        XCTAssertEqual(manager.activities.first?.steps, 5000, "Steps count should be correct.")
//    }
//
//    /// **Test: Steps to Active Minutes Conversion**
//    func testConvertStepsToMinutes() {
//        let minutes = Activity.convertStepsToMinutes(steps: 3000)
//        XCTAssertEqual(minutes, 30, "3000 steps should equal 30 active minutes.")
//    }
//
//    /// **Test: Streak Calculation**
//    func testCheckStreak() {
//        let today = Date()
//        guard let manager = activityManager else {
//                XCTFail("Activity Manager not initialized")
//                return
//        }
//        if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today),
//           let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today) {
//            let activities = [
//                Activity(
//                    date: today,
//                    steps: 6000,
//                    activeMinutes: 60,
//                    activityType: "Running"
//                ),
//                Activity(
//                    date: yesterday,
//                    steps: 7000,
//                    activeMinutes: 70,
//                    activityType: "Cycling"
//                ),
//                Activity(
//                    date: twoDaysAgo,
//                    steps: 9000,
//                    activeMinutes: 90,
//                    activityType: "Walking"
//                )
//            ]
//            
//            manager.activities = activities
//            let streak = manager.checkStreak()
//
//            XCTAssertEqual(streak, 3, "The streak should be 3 days long.")
//        }
//    }
//    
//    /// **Test: Streak Calculation - Broken Streak**
//       func testCheckStreakWithBreak() {
//           let today = Date()
//           guard let manager = activityManager else {
//               XCTFail("Activity Manager not initialized")
//               return
//           }
//
//           if let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: today),
//              let fiveDaysAgo = Calendar.current.date(byAdding: .day, value: -5, to: today) {
//               let activities = [
//                   Activity(date: today, steps: 8000, activeMinutes: 80, activityType: "Running"),
//                   Activity(date: threeDaysAgo, steps: 7000, activeMinutes: 70,  activityType: "Cycling"),
//                   Activity(date: fiveDaysAgo, steps: 10000, activeMinutes: 100, activityType: "Swimming")
//               ]
//               
//               manager.activities = activities
//               let streak = manager.checkStreak()
//               
//               XCTAssertEqual(streak, 1, "The streak should reset because of the 2-day gap.")
//           }
//       }
//
//       /// **Test: Weekly Summary Fetching**
//       func testGetWeeklySummary() {
//           let today = Date()
//           guard let manager = activityManager else {
//               XCTFail("Activity Manager not initialized")
//               return
//           }
//
//           if let oneDayAgo = Calendar.current.date(byAdding: .day, value: -1, to: today),
//              let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: today),
//              let eightDaysAgo = Calendar.current.date(byAdding: .day, value: -8, to: today) {  // This should be excluded
//               
//               let activities = [
//                   Activity(date: today, steps: 6000, activeMinutes: 60, activityType: "Running"),
//                   Activity(date: oneDayAgo, steps: 5000, activeMinutes: 50, activityType: "Jogging"),
//                   Activity(date: threeDaysAgo, steps: 4000, activeMinutes: 40, activityType: "Walking"),
//                   Activity(date: eightDaysAgo, steps: 3000, activeMinutes: 30, activityType: "Yoga") // Should NOT be included
//               ]
//               
//               manager.activities = activities
//               let weeklySummary = manager.getWeeklySummary()
//               
//               XCTAssertEqual(weeklySummary.count, 3, "Weekly summary should only include activities from the past 7 days.")
//           }
//       }
//
//    /// **Test: Fetch Today's Activity**
//    func testGetTodayActivity() {
//        let today = Date()
//        guard let manager = activityManager else {
//                XCTFail("Activity Manager not initialized")
//                return
//        }
//        let activity = Activity(
//            date: today,
//            steps: 4000,
//            activeMinutes: 40,
//            activityType: "Jogging"
//        )
//
//        manager.logActivityToView(activity)
//        let todayActivity = manager.getTodayActivity()
//
//        XCTAssertNotNil(todayActivity, "Today's activity should be found.")
//        XCTAssertEqual(todayActivity?.steps, 4000, "Today's activity steps should be correct.")
//    }
//    
////    /// **Test: Motivational Message**
////    func testTriggerMotivation() {
////        guard let manager = activityManager else {
////                XCTFail("Activity Manager not initialized")
////                return
////        }
////        let activity = Activity(
////            date: Date(),
////            steps: 5000,
////            activeMinutes: 50,
////            activityType: "Running"
////        )
////        manager.logActivityToView(activity)
////
////        let message = manager.triggerMotivation()
////        XCTAssertTrue(message.contains("Keep going!"), "Message should encourage user to complete 60 minutes.")
////    }
//    
//    func testSendActivityReminder() {
//        guard let manager = activityManager else {
//            XCTFail("Activity Manager not initialized")
//            return
//        }
//
//        let mockActivities: [Activity] = [
//            {
//                guard let date = Calendar.current.date(byAdding: .hour, value: -2, to: Date()) else {
//                    fatalError("Failed to create mock date")
//                }
//                return Activity(
//                    date: date,
//                    steps: 3000,
//                    activeMinutes: 30,
//                    activityType: "Running"
//                )
//            }(),
//            {
//                guard let date = Calendar.current.date(byAdding: .hour, value: -1, to: Date()) else {
//                    fatalError("Failed to create mock date")
//                }
//                return Activity(
//                    date: date,
//                    steps: 2000,
//                    activeMinutes: 20,
//                    activityType: "Walking"
//                )
//            }()
//        ]
//
//        manager.activities = mockActivities  // Assign activities to the manager
//        manager.sendActivityReminder()       // Call the function from manager
//
//        let totalActiveMinutes = manager.activities.reduce(0) { $0 + $1.activeMinutes }
//
//        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
//            if totalActiveMinutes >= 60 {
//                XCTAssertFalse(requests.contains { $0.identifier == "activityReminder" }, "No reminder should be scheduled if goal is met.")
//            } else {
//                XCTAssertTrue(requests.contains { $0.identifier == "activityReminder" }, "A reminder should be scheduled if goal is not met.")
//            }
//
//            // Additional Checks
//            XCTAssertEqual(
//                requests.filter { $0.identifier == "activityReminder" }.count,
//                totalActiveMinutes < 60 ? 1 : 0,
//                "There should be exactly one reminder if total minutes are below 60."
//            )
//            
//            if let reminder = requests.first(where: { $0.identifier == "activityReminder" }) {
//                XCTAssert(reminder.content.body.contains("minutes away"), "Notif body should include remaining minutes message when goal is not met.")
//                if totalActiveMinutes < 60 {
//                    XCTAssert(reminder.trigger is UNTimeIntervalNotificationTrigger, "Notification trigger should be time-based.")}
//            }
//        }
//    }
    
//    /// **Test: Store Activity in Firestore**
//        func testStoreActivity() async throws {
//            guard let manager = activityManager else {
//                XCTFail("Activity Manager not initialized")
//                return
//            }
//
//            let activity = Activity(
//                date: Date(),
//                steps: 6000,
//                activeMinutes: 60,
//                activityType: "Running"
//            )
//
//            do {
//                try await standard.store(activity: activity)
//                
//                // Fetch stored data to verify
//                let snapshot = try await mockUserDocRef.collection("activities").getDocuments()
//                let storedActivities = snapshot.documents.map { try? $0.data(as: Activity.self) }
//                
//                XCTAssertFalse(storedActivities.isEmpty, "Activity should be stored in Firestore.")
//                XCTAssertEqual(storedActivities.first??.steps, 6000, "Stored activity steps should match.")
//                XCTAssertEqual(storedActivities.first??.activeMinutes, 60, "Stored activity minutes should match.")
//                XCTAssertEqual(storedActivities.first??.activityType, "Running", "Stored activity type should match.")
//
//            } catch {
//                XCTFail("Failed to store activity: \(error)")
//            }
//        }
}
