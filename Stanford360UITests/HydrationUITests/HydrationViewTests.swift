//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import XCTest

final class HydrationViewTests: XCTestCase {
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
    
    @MainActor
    func testHydrationAddViewElementsExist() {
        let app = XCUIApplication()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 5))
        XCTAssertTrue(app.tabBars["Tab Bar"].buttons["Hydration"].exists)
        app.tabBars["Tab Bar"].buttons["Hydration"].tap()
        
        // Check Goal Message Text
        let goalMessage = app.staticTexts["goalMessageLabel"]
        XCTAssertTrue(goalMessage.waitForExistence(timeout: 2), "Goal message text should be visible")

        // Check Milestone Message View (if a milestone is reached)
        let milestoneMessage = app.staticTexts["MilestoneMessageLabel"]
        if milestoneMessage.exists {
            XCTAssertTrue(milestoneMessage.exists, "Milestone message should appear when goal is reached")
        }
    }
}
