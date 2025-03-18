//
//  ProteinAddView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/10/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProteinAddView: View {
	@Environment(ProteinManager.self) private var proteinManager
	
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                // motivationText
                
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
                .frame(height: 210)
                .padding(.top, 30)
                
                Text.goalMessage(current: proteinManager.getTodayTotalGrams(), goal: 60, unit: "g")
                    .padding(.top, 10)
                
                Spacer()
                // TODO - add meal logging interface to add view  // swiftlint:disable:this todo
            }
            MilestoneMessageView(unit: "grams of protein")
                .environmentObject(proteinManager.milestoneManager)
                .offset(y: -250)
        }
    }
}

#Preview {
	@Previewable @State var proteinManager = ProteinManager(meals: mealsData)
    ProteinAddView()
		.environment(proteinManager)
}
