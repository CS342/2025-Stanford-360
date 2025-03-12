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
        ZStack {
            VStack(spacing: 20) {
                // motivationText
                
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
                .padding(.top, 30)
                
                Text.goalMessage(current: Double(activityManager.getTodayTotalMinutes()), goal: 60, unit: "min")
                    .padding(.top, 10)
                
                Spacer()
                // TODO - add buttons to log activity  // swiftlint:disable:this todo
            }
            
            MilestoneMessageView(unit: "minutes of activity")
                .environmentObject(activityManager.milestoneManager)
                .offset(y: -250)
        }
    }
	
    /*
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
     */
}

#Preview {
	@Previewable @State var activityManager = ActivityManager(activities: activitiesData)
    ActivityAddView()
		.environment(activityManager)
}
