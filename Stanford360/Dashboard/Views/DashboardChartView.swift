//
//  DashboardChartView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/2/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct DashboardChartView: View {
	var timeFrame: TimeFrame
	
	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			Text(timeFrame.title)
				.font(.headline)
				.padding(.horizontal)
				.foregroundColor(Color.textPrimary)
			DashboardChart(timeFrame: timeFrame)
		}
		.padding(.top, 20)
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
	}
}

#Preview {
	DashboardChartView(timeFrame: .month)
}
