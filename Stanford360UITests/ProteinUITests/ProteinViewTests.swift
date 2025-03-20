// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest

final class ProteinViewTests: XCTestCase {
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
    
    // Test Add Protein Button Functionality
    @MainActor
    func testAddProteinButton() throws {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
        
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Protein"].exists)
        app.tabBars["Tab Bar"].buttons["Protein"].tap()
        
        let addProteinButton = app.buttons["Add Protein Button"]
        XCTAssertTrue(addProteinButton.waitForExistence(timeout: 2), "Add Protein button should exist")
        addProteinButton.tap()
        
        let addMealView = app.otherElements["AddMealView"]
        XCTAssertTrue(addMealView.waitForExistence(timeout: 2), "Add Meal View should appear when Add Protein button is tapped")
    }
}
