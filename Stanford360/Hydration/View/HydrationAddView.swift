//
//  HydrationAddView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/10/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct HydrationAddView: View {
	@Environment(HydrationManager.self) private var hydrationManager
	
	var body: some View {
        ZStack {
            VStack(spacing: 20) {
                // motivationText

                PercentageRing(
                    currentValue: Int(hydrationManager.getTodayTotalOunces()),
                    maxValue: 60,
                    iconName: "drop.fill",
                    ringWidth: 25,
                    backgroundColor: .hydrationColorBackground,
                    foregroundColors: [.hydrationColor, .hydrationColorGradient],
                    unitLabel: "ounces",
                    iconSize: 13,
                    showProgressTextInCenter: true
                )
                .frame(height: 210)
                .padding(.top, 30)
                
                Text.goalMessage(current: hydrationManager.getTodayTotalOunces(), goal: 60, unit: "oz")
                    .padding(.top, 10)
                
                // TODO() - make into reusable component to share with activity view	// swiftlint:disable:this todo
                //			HydrationControlPanel()
                //				.contentShape(Rectangle()) // Ensure the gesture recognizer covers the whole area
                //				.simultaneousGesture(
                //					DragGesture(minimumDistance: 5)
                //						.onChanged { value in
                //							// Only block if it's more horizontal than vertical
                //							let isHorizontalDrag = abs(value.translation.width) > abs(value.translation.height)
                //							if isHorizontalDrag {
                //								// Do nothing - just preventing the swipe from propagating
                //							}
                //						}
                //				)
                
                Spacer()
            }
            
            MilestoneMessageView(unit: "oz of water")
                .environmentObject(hydrationManager.milestoneManager)
                .offset(y: -100)
        }
	}
	
    /*
	private var motivationText: some View {
		Text(hydrationManager.triggerMotivation())
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
	@Previewable @State var scheduler = Stanford360Scheduler()
	@Previewable @State var hydrationManager = HydrationManager(hydration: [])
	HydrationAddView()
		.environment(hydrationManager)
		.environment(scheduler)
}
