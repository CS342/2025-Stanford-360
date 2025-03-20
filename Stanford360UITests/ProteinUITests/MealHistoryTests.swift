// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest

final class MealHistoryTests: XCTestCase {
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
    
    // Test Meal History Displays Entries
    @MainActor
    func testMealHistoryDisplaysLogs() throws {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
        
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Protein"].exists)
        app.tabBars["Tab Bar"].buttons["Protein"].tap()
        
        let historyButton = app.segmentedControls.buttons["History"]
        XCTAssertTrue(historyButton.waitForExistence(timeout: 2), "History tab should exist")
        historyButton.tap()
        
        let addButton = app.buttons["Add"]
        addButton.tap()
        
        let logButton = app.buttons["logMealButton"]
        XCTAssertTrue(app.staticTexts["Chicken Breast"].waitForExistence(timeout: 2), "Preset button for Chicken Breast should exist")
        app.staticTexts["Chicken Breast"].tap()
        logButton.tap()
        
        historyButton.tap()
        
        let mealLogEntry = app.staticTexts["mealLogEntry"]
        XCTAssertTrue(mealLogEntry.waitForExistence(timeout: 2), "Meal log entry should be displayed if logs exist.")
    }
}
