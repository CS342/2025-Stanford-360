//
//  ProgressRings.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 2/26/25.
//	Inspired by Frank Gia https://medium.com/@frankjia/creating-activity-rings-in-swiftui-11ef7d336676
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProgressRings: View {
	@Environment(ActivityManager.self) private var activityManager
	@Environment(HydrationManager.self) private var hydrationManager
	@Environment(ProteinManager.self) private var proteinManager
	
	private let ringWidth: CGFloat = 35
	private let ringSpacing: CGFloat = 5
	private let baseRingSize: CGFloat = 120
	private let iconSize: CGFloat = 16
	
	var body: some View {
		ZStack {
			// Activity Ring
			let activityRingSize = baseRingSize + (ringSpacing + ringWidth) * 4
			PercentageRing(
				currentValue: activityManager.getTodayTotalMinutes(),
				maxValue: 60,
				iconName: "figure.walk",
				ringWidth: ringWidth,
				backgroundColor: .activityColorBackground,
				foregroundColors: [.activityColor, .activityColorGradient],
				iconSize: iconSize + 2
			)
			.frame(width: activityRingSize, height: activityRingSize)
			.accessibilityLabel("Activity Progress")
			
			// Hydration Ring
			let hydrationRingSize = baseRingSize + (ringSpacing + ringWidth) * 2
			PercentageRing(
				currentValue: Int(hydrationManager.getTodayTotalOunces()),
				maxValue: 60,
				iconName: "drop.fill",
				ringWidth: ringWidth,
				backgroundColor: .hydrationColorBackground,
				foregroundColors: [.hydrationColor, .hydrationColorGradient],
				iconSize: iconSize
			)
			.frame(width: hydrationRingSize, height: hydrationRingSize)
			.accessibilityLabel("Hydration Progress")
			
			// Protein Ring
			PercentageRing(
				currentValue: Int(proteinManager.getTodayTotalGrams()),
				maxValue: 60,
				iconName: "fork.knife",
				ringWidth: ringWidth,
				backgroundColor: .proteinColorBackground,
				foregroundColors: [.proteinColor, .proteinColorGradient],
				iconSize: iconSize
			)
			.frame(width: baseRingSize, height: baseRingSize)
			.accessibilityLabel("Protein Progress")
		}
		.padding(.vertical, 30)
		.frame(maxWidth: .infinity)
	}
}

#Preview {
	ProgressRings()
}
