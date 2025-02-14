//
//  ActivityViewTest.swift
//  Stanford360UITests
//
//  Created by Elsa Bismuth on 07/02/2025.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions

 class ActivityViewUITests: XCTestCase {
//    @MainActor
//    override func setUp() async throws {
//        continueAfterFailure = false
//        
//        let app = XCUIApplication()
//        app.launchArguments = ["--skipOnboarding"]
//        app.deleteAndLaunch(withSpringboardAppName: "Stanford360")
//    }
//
//    @MainActor
//    func testActivityLoggingFlow() throws {
//        let app = XCUIApplication()
//        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
//
//        XCTAssertTrue(app.navigationBars["Activity Tracker"].exists)
//
//        // Check input fields
//        let activityTypeField = app.textFields["Activity Type"]
//        let stepsField = app.textFields["Steps"]
//        
//        XCTAssertTrue(activityTypeField.exists)
//        XCTAssertTrue(stepsField.exists)
//        
//        // Enter activity data
//        activityTypeField.tap()
//        activityTypeField.typeText("Running")
//
//        stepsField.tap()
//        stepsField.typeText("3000")
//
//        // Log Activity
//        let logButton = app.buttons["Log Activity"]
//        XCTAssertTrue(logButton.exists)
//        logButton.tap()
//        
//        // Ensure input fields are cleared after logging
//        XCTAssertEqual(activityTypeField.value as? String, "")
//        XCTAssertEqual(stepsField.value as? String, "")
//
//        // Verify new activity appears in the list
//        XCTAssertTrue(app.staticTexts["Running"].waitForExistence(timeout: 2.0))
//        XCTAssertTrue(app.staticTexts["3000"].waitForExistence(timeout: 2.0))
//    }
//
//    @MainActor
//    func testDeleteActivity() throws {
//        let app = XCUIApplication()
//        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
//
//        let firstActivity = app.tables.cells.firstMatch
//        XCTAssertTrue(firstActivity.exists)
//
//        firstActivity.swipeLeft()
////        app.buttons["Delete"].tap()
//
//        // Ensure activity is removed
//        XCTAssertFalse(firstActivity.exists)
//    }
}
