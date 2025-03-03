//
//  ProteinTodayView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/2/25.
//
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProteinTodayView: View {
	@Environment(ProteinManager.self) private var proteinManager
	
	var body: some View {
		DailyRecordView(currentValue: proteinManager.getTodayTotalGrams(), maxValue: 60)
			.frame(height: 220)
			.frame(maxWidth: .infinity, alignment: .center)
			.padding(.top, 50) // Add spacing to prevent overlap
			.padding(.bottom, 20) // Ensure separation
	}
}

#Preview {
	@Previewable @State var proteinManager = ProteinManager(meals: mealsData)
	ProteinTodayView()
		.environment(proteinManager)
}
