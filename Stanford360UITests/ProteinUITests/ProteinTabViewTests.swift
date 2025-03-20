// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest

final class ProteinTabViewTests: XCTestCase {
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
    
    // Test Protein Tab View Navigation
    @MainActor
    func testProteinTabViewNavigation() throws {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
        
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Protein"].exists)
        app.tabBars["Tab Bar"].buttons["Protein"].tap()
        
        let addTab = app.segmentedControls.buttons["Add"]
        XCTAssertTrue(addTab.waitForExistence(timeout: 2), "Add tab should exist")
        addTab.tap()
        
        let historyTab = app.segmentedControls.buttons["History"]
        XCTAssertTrue(historyTab.waitForExistence(timeout: 2), "History tab should exist")
        historyTab.tap()
        
        let discoverTab = app.segmentedControls.buttons["Discover"]
        XCTAssertTrue(discoverTab.waitForExistence(timeout: 2), "Discover tab should exist")
        discoverTab.tap()
    }
}
