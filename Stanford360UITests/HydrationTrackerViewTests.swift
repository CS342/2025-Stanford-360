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
        
        // XCTAssertTrue(app.tabBars.buttons["Hydration"].waitForExistence(timeout: 2), "Hydration tab should exist")
        // app.tabBars.buttons["Hydration"].tap()
    }
 /*
    /// **Test: UI Elements Exist**
    @MainActor
    func testUIElementsExist() {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.staticTexts["Hydration Tracker Header"].waitForExistence(timeout: 2), "Header should exist")
        XCTAssertTrue(app.buttons["logWaterIntakeButton"].waitForExistence(timeout: 2), "Log Water Intake button should exist")
        XCTAssertTrue(app.staticTexts["8 oz"].waitForExistence(timeout: 2), "Preset button for 8 oz should exist")
        if app.staticTexts["streakLabel"].exists {
                XCTAssertTrue(app.staticTexts["streakLabel"].exists, "Streak label should exist if the streak is greater than 0")
        }
    }

    /// **Test: Logging Water Intake Updates Progress Bar**
    @MainActor
    func testProgressBarUpdatesAfterLoggingWaterIntake() {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.staticTexts["12 oz"].waitForExistence(timeout: 2), "Preset button for 12 oz should exist")
        app.staticTexts["12 oz"].tap()
        app.buttons["logWaterIntakeButton"].tap()
        let progressBarLabel = app.staticTexts["progressBarLabel"]
        XCTAssertTrue(progressBarLabel.waitForExistence(timeout: 2), "Progress bar label should exist")
    }
  */

    /*
    /// **Test: Logging 60oz Increases Streak**
    @MainActor
    func testStreakIncreases() {
        let app = XCUIApplication()
        let logButton = app.buttons["logWaterIntakeButton"]

        var initialStreak = 0
        if app.staticTexts["streakLabel"].exists {
            let streakLabel = app.staticTexts["streakLabel"]
            initialStreak = extractStreak(from: streakLabel.label)
        }
        
        for _ in 1...3 {
            XCTAssertTrue(app.staticTexts["20 oz"].waitForExistence(timeout: 2), "Preset button for 20 oz should exist")
            app.staticTexts["20 oz"].tap()
            logButton.tap()
        }
        
        let streakLabel = app.staticTexts["streakLabel"]
        XCTAssertTrue(streakLabel.waitForExistence(timeout: 3), "Streak label should exist after logging 60 oz intake")

        let updatedStreak = extractStreak(from: streakLabel.label)
        
        if initialStreak < updatedStreak {
            XCTAssertEqual(updatedStreak, initialStreak + 1, "Streak should increase by 1 if it wasn't already updated")
        } else {
            XCTAssertEqual(updatedStreak, initialStreak, "Streak should remain the same if it was already updated today")
        }
    }
     */

    /*
    /// **Extracts the streak value from the streak label**
    private func extractStreak(from text: String) -> Int {
        let pattern = "[0-9]+"

        guard let regex = try? NSRegularExpression(pattern: pattern),
        let match = regex.firstMatch(in: text, range: NSRange(location: 0, length: text.utf16.count)),
        let range = Range(match.range, in: text) else {
            return 0
        }

        let numberString = String(text[range])
        return Int(numberString) ?? 0
    }
     */
    
    /*
    /// **Test: Invalid Input Shows Error**
    @MainActor
        func testErrorWhenNoPresetSelected() {
            let app = XCUIApplication()
            app.buttons["logWaterIntakeButton"].tap()
            
            let errorLabel = app.staticTexts["errorMessageLabel"]
            XCTAssertTrue(errorLabel.waitForExistence(timeout: 2), "Error message should appear if no preset is selected")
        }
     */
    
    /*
    /// **Test: Milestone Message Appears**
    @MainActor
        func testMilestoneMessageAppears() {
            let app = XCUIApplication()
            
            for _ in 1...3 {
                XCTAssertTrue(app.staticTexts["20 oz"].exists, "Preset button for 20 oz should exist")
                app.staticTexts["20 oz"].tap()
                app.buttons["logWaterIntakeButton"].tap()
            }
            
            let milestoneLabel = app.staticTexts["milestoneMessageLabel"]
            XCTAssertTrue(milestoneLabel.waitForExistence(timeout: 2), "Milestone message should appear after logging enough water")
        }
     */

    /*
    /// t**Test: Reaching Goal Shows Success Message**
    @MainActor
    func testGoalReachedMessage() {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.staticTexts["32 oz"].exists, "Preset button for 32 oz should exist")
        app.staticTexts["32 oz"].tap()
        app.buttons["logWaterIntakeButton"].tap()
        
        app.staticTexts["32 oz"].tap()
        app.buttons["logWaterIntakeButton"].tap()
        
        let successMessage = app.staticTexts["goalReachedLabel"]
        XCTAssertTrue(successMessage.waitForExistence(timeout: 3), "Success message should appear when reaching the 60 oz goal")
    }
     */
}
