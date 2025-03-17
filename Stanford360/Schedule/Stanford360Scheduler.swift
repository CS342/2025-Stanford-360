//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import Spezi
import SpeziScheduler
import SpeziViews
import class ModelsR4.Questionnaire
import class ModelsR4.QuestionnaireResponse


@Observable
final class Stanford360Scheduler: Module, DefaultInitializable, EnvironmentAccessible {
    @Dependency(Scheduler.self) @ObservationIgnored internal var scheduler
	// periphery:ignore - todo(kelly) - investigate further
	@Dependency(AppNavigationState.self) @ObservationIgnored internal var navigationState

    @MainActor var viewState: ViewState = .idle
	
	internal let dailyMorningNotificationTaskID = "daily-morning-notification"
	internal let saturdayWeightNotificationTaskID = "saturday-weight-notification"
	internal let sundayWeightNotificationTaskID = "sunday-weight-notification"
	
	internal let belowHalfActivity5PMNotificationTaskID = "below-half-activity-5pm-notif"
	// periphery:ignore
	internal let halfActivity5PMNotificationTaskID = "half-activity-5pm-notif"
	// periphery:ignore
	internal let fullActivity5PMNotificationTaskID = "full-activity-5pm-notif"
	// periphery:ignore
	internal let halfActivityImmediateNotificationTaskID = "half-activity-immediate-notif"
	// periphery:ignore
	internal let fullActivityImmediateNotificationTaskID = "full-activity-immediate-notif"
		
	// periphery:ignore
	internal let dateRange1Day: Range<Date> = Date()..<Date().addingTimeInterval(60 * 60 * 24 * 1)

    init() {}
    
    /// Add or update the current list of task upon app startup.
    func configure() {
        configurePatientScheduler()
		configureActivityScheduler()
		configureHydrationScheduler()
    }
}


extension Task.Context {
    @Property(coding: .json) var questionnaire: Questionnaire?
}


extension Outcome {
    // periphery:ignore - demonstration of how to store additional context within an outcome
    @Property(coding: .json) var questionnaireResponse: QuestionnaireResponse?
}
