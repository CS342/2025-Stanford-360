//
//  ActivityAddView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/10/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct ActivityAddView: View {
	@Environment(ActivityManager.self) private var activityManager
	
    var body: some View {
		VStack(spacing: 20) {
			motivationText
			
			PercentageRing(
				currentValue: activityManager.getTodayTotalMinutes(),
				maxValue: 60,
				iconName: "figure.walk",
				ringWidth: 25,
				backgroundColor: Color.activityColorBackground,
				foregroundColors: [Color.activityColor, Color.activityColorGradient],
				unitLabel: "minutes",
				iconSize: 13,
				showProgressTextInCenter: true
			)
			.frame(maxHeight: 210)
			
			MilestoneMessageView(unit: "minutes of activity")
				.environmentObject(activityManager.milestoneManager)
				.offset(y: -175)
			
			Spacer()
			// TODO - add buttons to log activity  // swiftlint:disable:this todo
		}
    }
	
	// TODO() - decompose and align with other views	// swiftlint:disable:this todo
	private var motivationText: some View {
		Text(activityManager.triggerMotivation())
			.font(.headline)
			.foregroundColor(.blue)
			.padding()
			.background(
				RoundedRectangle(cornerRadius: 15)
					.fill(Color.blue.opacity(0.1))
			)
	}
}

#Preview {
	@Previewable @State var activityManager = ActivityManager(activities: activitiesData)
    ActivityAddView()
		.environment(activityManager)
}
