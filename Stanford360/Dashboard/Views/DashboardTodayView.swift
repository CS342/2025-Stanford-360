//
//  DashboardTodayView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/2/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct DashboardTodayView: View {
	@Environment(ActivityManager.self) private var activityManager
	@Environment(ProteinManager.self) private var proteinManager
	@Environment(HydrationManager.self) private var hydrationManager
	
	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 0) {
				ProgressRings()
				
				VStack(spacing: 15) {
					ProgressCard(
						title: "Activity",
						progress: CGFloat(activityManager.getTodayTotalMinutes()),
						color: .activityColor,
						streak: activityManager.streak
					)
					
					ProgressCard(
						title: "Hydration",
						progress: CGFloat(hydrationManager.getTodayTotalOunces()),
						color: .hydrationColor,
						streak: hydrationManager.streak
					)
					
					ProgressCard(
						title: "Protein",
						progress: CGFloat(proteinManager.getTodayTotalGrams()),
						color: .proteinColor,
						streak: proteinManager.streak
					)
				}
				.padding(.horizontal, 20)
			}
		}
	}
}

#Preview {
	DashboardTodayView()
}
