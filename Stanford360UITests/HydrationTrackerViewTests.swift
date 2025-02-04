//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest

final class HydrationTrackerViewTests: XCTestCase {
    @MainActor
    override func setUp() async throws {
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding"]
        app.launch()
        
        XCTAssertTrue(app.tabBars.buttons["Hydration"].waitForExistence(timeout: 2), "Hydration tab should exist")
        app.tabBars.buttons["Hydration"].tap()
    }
 
    /// **Test: UI Elements Exist**
    @MainActor
    func testUIElementsExist() {
        let app = XCUIApplication()
        XCTAssertTrue(app.textFields["intakeInputField"].waitForExistence(timeout: 2), "Intake input field should exist")
        XCTAssertTrue(app.buttons["logWaterIntakeButton"].waitForExistence(timeout: 2), "Log Water Intake button should exist")
        XCTAssertTrue(app.staticTexts["totalIntakeLabel"].waitForExistence(timeout: 2), "Total Intake label should exist")
        XCTAssertTrue(app.staticTexts["streakLabel"].waitForExistence(timeout: 2), "Streak label should exist")
    }

    /// **Test: Logging Water Intake Updates Total Intake**
    @MainActor
    func testLoggingWaterIntake() {
        let app = XCUIApplication()
        let intakeField = app.textFields["intakeInputField"]
        let logButton = app.buttons["logWaterIntakeButton"]
        let totalIntakeLabel = app.staticTexts["totalIntakeLabel"]
        let initialIntakeText = totalIntakeLabel.label
        let initialIntake = extractIntake(from: initialIntakeText)

        intakeField.tap()
        intakeField.typeText("12")
        logButton.tap()
        
        let expectedIntake = initialIntake + 12.0
        let expectedIntakeString = String(format: "%.1f", expectedIntake)

        XCTAssertTrue(totalIntakeLabel.waitForExistence(timeout: 2), "Total Intake label should exist")
        XCTAssertTrue(totalIntakeLabel.label.contains(expectedIntakeString), "Total Intake should update to \(expectedIntakeString) oz")
    }
    
    /// **Extracts the numeric intake value from the label string**
    private func extractIntake(from text: String) -> Double {
        let pattern = "[0-9]+(?:\\.[0-9]*)?"
        
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: text, range: NSRange(location: 0, length: text.utf16.count)),
              let range = Range(match.range, in: text) else {
            return 0.0
        }
        
        let numberString = String(text[range])
        return Double(numberString) ?? 0.0
    }

    /// **Test: Logging 60oz Increases Streak**
    @MainActor
    func testStreakIncreases() {
        let app = XCUIApplication()
        let intakeField = app.textFields["intakeInputField"]
        let logButton = app.buttons["logWaterIntakeButton"]
        let streakLabel = app.staticTexts["streakLabel"]

        intakeField.tap()
        intakeField.typeText("60")
        logButton.tap()

        XCTAssertTrue(streakLabel.waitForExistence(timeout: 2), "Streak label should exist")
        XCTAssertTrue(streakLabel.label.contains("Streak: 1 days!"), "Streak should be 1 day after reaching 60 oz")
    }

    /// ✅ **Test: Invalid Input Shows Error**
    @MainActor
    func testInvalidInputShowsError() {
        let app = XCUIApplication()
        let intakeField = app.textFields["intakeInputField"]
        let logButton = app.buttons["logWaterIntakeButton"]
        let errorLabel = app.staticTexts["errorMessageLabel"]

        intakeField.tap()
        intakeField.typeText("abc")
        logButton.tap()

        XCTAssertTrue(errorLabel.waitForExistence(timeout: 2), "Error message should appear for invalid input")
    }

    /// ✅ **Test: Reaching Goal Shows Success Message**
    @MainActor
    func testGoalReachedMessage() {
        let app = XCUIApplication()
        let intakeField = app.textFields["intakeInputField"]
        let logButton = app.buttons["logWaterIntakeButton"]
        let successMessage = app.staticTexts["🎉 Goal Reached! Stay Hydrated! 🎉"]

        intakeField.tap()
        intakeField.typeText("60")
        logButton.tap()

        XCTAssertTrue(successMessage.waitForExistence(timeout: 2), "Success message should appear when reaching 60 oz goal")
    }
}
