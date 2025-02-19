//
//  HealthKitActivityTests.swift
//  Stanford360Tests
//
//  Created by Elsa Bismuth on 14/02/2025.
//

@testable import Stanford360
import XCTest

final class HealthKitActivityTests: XCTestCase {
    func testToActivity() {
        // Given
        let date = Date()
        let healthKitActivity = HealthKitActivity(
            date: date,
            steps: 1000,
            activeMinutes: 30,
            caloriesBurned: 100,
            activityType: "HealthKit"
        )
        
        // When
        let activity = healthKitActivity.toActivity()
        
        // Then
        XCTAssertEqual(activity.date, date)
        XCTAssertEqual(activity.steps, 1000)
        XCTAssertEqual(activity.activeMinutes, 30)
        XCTAssertEqual(activity.caloriesBurned, 100)
        XCTAssertEqual(activity.activityType, "HealthKit")
    }
}
