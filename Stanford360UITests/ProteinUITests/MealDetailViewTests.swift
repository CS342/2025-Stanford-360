// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest

final class MealDetailViewTests: XCTestCase {
    @MainActor
    override func setUp() async throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding"]
        app.launch()
        
        let dontAllowIdentifier = app.buttons["UIA.Health.AuthSheet.CancelButton"]
        if dontAllowIdentifier.waitForExistence(timeout: 5) {
            dontAllowIdentifier.tap()
        }
    }
    
    // Test Meal Detail View Displays Information Correctly
    @MainActor
    func testMealDetailViewDisplaysInfo() throws {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
        
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Protein"].exists)
        app.tabBars["Tab Bar"].buttons["Protein"].tap()
        
        let historyButton = app.segmentedControls.buttons["History"]
        XCTAssertTrue(historyButton.waitForExistence(timeout: 2), "History tab should exist")
        historyButton.tap()
        
        let mealEntry = app.staticTexts["mealLogEntry"]
        XCTAssertTrue(mealEntry.waitForExistence(timeout: 2), "Meal log entry should exist")
        mealEntry.tap()
        
        let mealName = app.staticTexts["mealName"]
        XCTAssertTrue(mealName.waitForExistence(timeout: 2), "Meal name should be displayed")
        
        let proteinContent = app.staticTexts["Protein Content"]
        XCTAssertTrue(proteinContent.waitForExistence(timeout: 2), "Protein content card should be visible")
        
        let intakeTime = app.staticTexts["Intake time"]
        XCTAssertTrue(intakeTime.waitForExistence(timeout: 2), "Intake time card should be visible")
    }
}
