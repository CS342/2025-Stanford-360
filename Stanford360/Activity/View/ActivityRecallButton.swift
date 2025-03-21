//
//  ActivityRecallButton.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/17/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct ActivityRecallButton: View {
	@Environment(ActivityManager.self) private var activityManager
	@Environment(Stanford360Standard.self) private var standard
	
	var body: some View {
		Button(action: {
			Task {
				if let activity = activityManager.activities.last {
					await standard.deleteActivity(activity)
					var updatedActivities = activityManager.activities
					updatedActivities.removeLast(1)
					activityManager.activities = updatedActivities
				}
			}
		}) {
			Image(systemName: "arrow.uturn.backward.circle.fill")
				.font(.system(size: 40))
				.foregroundColor(.red)
				.accessibilityLabel("Undo last activity log")
		}
		.disabled(activityManager.getTodayTotalMinutes() == 0)
	}
}


#Preview {
	ActivityRecallButton()
}
