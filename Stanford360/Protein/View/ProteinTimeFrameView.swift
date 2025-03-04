//
//  ProteinTimeFrameView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/2/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProteinTimeFrameView: View {
	@State var selectedTimeFrame: TimeFrame = .today
	
    var body: some View {
		VStack {
			TimeFramePicker(selectedTimeFrame: $selectedTimeFrame)
						
			TabView(selection: $selectedTimeFrame) {
				ProteinTodayView()
					.tag(TimeFrame.today)
				ProteinWeekView()
					.tag(TimeFrame.week)
				ProteinMonthView()
					.tag(TimeFrame.month)
			}
			.tabViewStyle(PageTabViewStyle())
		}
    }
}

#Preview {
    ProteinTimeFrameView()
}
