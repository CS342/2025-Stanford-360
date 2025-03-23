//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

@testable import Stanford360
import XCTest

final class MilestoneManagerTests: XCTestCase {
    var milestoneManager: MilestoneManager?

    override func setUp() {
        super.setUp()
        milestoneManager = MilestoneManager()
    }

    override func tearDown() {
        milestoneManager = nil
        super.tearDown()
    }

    @MainActor
    func testRegularMilestoneMessage() {
        guard let milestoneManager = milestoneManager else {
            XCTFail("MilestoneManager is nil in testRegularMilestoneMessage")
            return
        }

        let milestoneData = milestoneManager.checkMilestones(
            newTotal: 40,
            lastMilestone: 20,
            unit: "oz",
            streak: 3
        )

        XCTAssertEqual(milestoneData.message, "Great job! You've reached 40 oz today!")
        XCTAssertFalse(milestoneData.isSpecial)
    }

    @MainActor
    func testSpecialMilestoneMessage() {
        guard let milestoneManager = milestoneManager else {
            XCTFail("MilestoneManager is nil in testSpecialMilestoneMessage")
            return
        }

        let milestoneData = milestoneManager.checkMilestones(
            newTotal: 60,
            lastMilestone: 40,
            unit: "oz",
            streak: 5
        )

        XCTAssertEqual(milestoneData.message, "Amazing! You've reached 60 oz today! 5 days in a row! Keep it going!")
        XCTAssertTrue(milestoneData.isSpecial)
    }

    @MainActor
    func testMilestoneMessageDisplay() {
        guard let milestoneManager = milestoneManager else {
            XCTFail("MilestoneManager is nil in testMilestoneMessageDisplay")
            return
        }

        milestoneManager.displayMilestoneMessage(
            newTotal: 60,
            lastMilestone: 40,
            unit: "oz",
            streak: 7
        )

        XCTAssertNotNil(milestoneManager.milestoneMessage)
        XCTAssertTrue(milestoneManager.isSpecialMilestone)

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            XCTAssertNil(milestoneManager.milestoneMessage)
            XCTAssertFalse(milestoneManager.isSpecialMilestone)
        }
    }

    @MainActor
    func testGetLatestMilestone() {
        guard let milestoneManager = milestoneManager else {
            XCTFail("MilestoneManager is nil in testGetLatestMilestone")
            return
        }

        XCTAssertEqual(milestoneManager.getLatestMilestone(total: 35), 20)
        XCTAssertEqual(milestoneManager.getLatestMilestone(total: 60), 60)
    }
}
