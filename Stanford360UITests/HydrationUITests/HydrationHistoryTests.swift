//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest

final class HydrationHistoryViewTests: XCTestCase {
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
    
    // Test Hydration History Displays Entries
    @MainActor
    func testHydrationHistoryDisplaysLogs() throws {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
        
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Hydration"].exists)
        app.tabBars["Tab Bar"].buttons["Hydration"].tap()
        
        let historyButton = app.segmentedControls.buttons["History"]
        XCTAssertTrue(historyButton.waitForExistence(timeout: 2), "History tab should exist")
        historyButton.tap()
        
        let addButton = app.buttons["Add"]
        addButton.tap()
        
        let logButton = app.buttons["logWaterIntakeButton"]
        XCTAssertTrue(app.staticTexts["20 oz"].waitForExistence(timeout: 2), "Preset button for 20 oz should exist")
        app.staticTexts["20 oz"].tap()
        logButton.tap()
        
        historyButton.tap()
        
        let hydrationLogEntry = app.staticTexts["hydrationLogEntry"]
        XCTAssertTrue(hydrationLogEntry.waitForExistence(timeout: 2), "Hydration log entry should be displayed if logs exist.")
    }
}
