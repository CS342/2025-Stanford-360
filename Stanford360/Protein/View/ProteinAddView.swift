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
		VStack(spacing: 20) {
			motivationText
			
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
			
			Spacer()
			// TODO - add meal logging interface to add view  // swiftlint:disable:this todo
		}
    }
	
	// TODO() - decompose and align with other views	// swiftlint:disable:this todo
	private var motivationText: some View {
		Text(proteinManager.triggerMotivation())
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
	@Previewable @State var proteinManager = ProteinManager(meals: mealsData)
    ProteinAddView()
		.environment(proteinManager)
}
