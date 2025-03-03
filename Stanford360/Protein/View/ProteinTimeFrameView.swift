//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
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
