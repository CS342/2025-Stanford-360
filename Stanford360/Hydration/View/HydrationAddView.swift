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
                
                Spacer()
            }
            
            MilestoneMessageView(unit: "oz of water")
                .environmentObject(hydrationManager.milestoneManager)
                .offset(y: -100)
        }
	}
}

#Preview {
	@Previewable @State var scheduler = Stanford360Scheduler()
	@Previewable @State var hydrationManager = HydrationManager(hydration: [])
	HydrationAddView()
		.environment(hydrationManager)
		.environment(scheduler)
}
