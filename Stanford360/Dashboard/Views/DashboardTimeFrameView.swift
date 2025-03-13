//
//  DashboardTimeFrameView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/2/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct DashboardTimeFrameView: View {
	@State var selectedTimeFrame: TimeFrame = .today
	
    var body: some View {
		VStack {
			TimeFramePicker(selectedTimeFrame: $selectedTimeFrame)
						
			TabView(selection: $selectedTimeFrame) {
				DashboardTodayView()
					.tag(TimeFrame.today)
				DashboardWeeklyView()
					.tag(TimeFrame.week)
//				DashboardMonthlyView()
//					.tag(TimeFrame.month)
			}
			.tabViewStyle(PageTabViewStyle())
		}
    }
}

#Preview {
	DashboardTimeFrameView()
}
