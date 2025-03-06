//
//  ProteinTodayView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/2/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProteinTodayView: View {
	@Environment(ProteinManager.self) private var proteinManager
	
    var body: some View {
        ZStack {
            PercentageRing(
                currentValue: Int(proteinManager.getTodayTotalGrams()),
                maxValue: 60,
                iconName: "fork.knife",
                ringWidth: 25,
                backgroundColor: Color.proteinColorBackground,
                foregroundColors: [Color.proteinColor, Color.proteinColorGradient],
                unitLabel: "grams",
                iconSize: 13,
                showProgressTextInCenter: true
            )
            .frame(maxHeight: 210)
            
            MilestoneMessageView(unit: "grams of protein")
                .environmentObject(proteinManager.milestoneManager)
                .offset(y: -100)
        }
    }
}

#Preview {
	@Previewable @State var proteinManager = ProteinManager(meals: mealsData)
	ProteinTodayView()
		.environment(proteinManager)
}
