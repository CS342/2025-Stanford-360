//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest

final class HydrationControlPanelTests: XCTestCase {
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

    // MARK: - Test: Log Water Intake Button Exists and is Clickable
    @MainActor
    func testLogWaterIntakeButton() {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Hydration"].exists)
        app.tabBars["Tab Bar"].buttons["Hydration"].tap()
        
        let logButton = app.buttons["logWaterIntakeButton"]
        XCTAssertTrue(logButton.waitForExistence(timeout: 2), "Log Water Intake button should exist")
        logButton.tap()
    }

    // MARK: - Test: Error Message Appears When No Amount is Selected
    @MainActor
    func testErrorMessageAppears() {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Hydration"].exists)
        app.tabBars["Tab Bar"].buttons["Hydration"].tap()
        
        let logButton = app.buttons["logWaterIntakeButton"]
        logButton.tap()

        let errorLabel = app.staticTexts["errorMessageLabel"]
        XCTAssertTrue(errorLabel.waitForExistence(timeout: 2), "Error message should appear if no amount is selected")
    }

    // MARK: - Test: Selecting a Hydration Amount and Logging Intake
    @MainActor
    func testHydrationAmountButtons() {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Hydration"].exists)
        app.tabBars["Tab Bar"].buttons["Hydration"].tap()
        
        let hydrationAmounts = ["8 oz", "10 oz", "12 oz", "16 oz", "20 oz", "32 oz"]
        
        for amount in hydrationAmounts {
            let amountButton = app.staticTexts[amount]
            XCTAssertTrue(amountButton.waitForExistence(timeout: 2), "\(amount) selection should exist")
            amountButton.tap()
        }
    }

    // MARK: - Test: Recall Last Intake
    @MainActor
    func testRecallLastIntake() {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Hydration"].exists)
        app.tabBars["Tab Bar"].buttons["Hydration"].tap()
        
        let recallButton = app.buttons["Recall Last Intake"]
        
        if recallButton.exists {
            recallButton.tap()
            XCTAssertTrue(recallButton.isHittable, "Recall button should be tappable")
        } else {
            XCTFail("Recall Last Intake button does not exist")
        }

        XCTAssertTrue(recallButton.waitForExistence(timeout: 2), "Recall Last Intake button should exist")

        // Check that at least one hydration log entry exists before tapping
        let hydrationLogEntry = app.staticTexts["hydrationLogEntry"]
        let initialExists = hydrationLogEntry.exists

        recallButton.tap()

        // If a log existed, wait for it to disappear
        if initialExists {
            XCTAssertFalse(hydrationLogEntry.waitForExistence(timeout: 2), "Hydration log should be removed after tapping Recall Last Intake.")
        }
    }
}
