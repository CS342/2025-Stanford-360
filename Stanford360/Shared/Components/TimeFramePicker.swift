//
//  TimeFramePicker.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/2/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct TimeFramePicker: View {
	@Binding var selectedTimeFrame: TimeFrame
	
    var body: some View {
		Picker("Time Frame", selection: $selectedTimeFrame) {
			Text("Today").tag(TimeFrame.today)
			Text("This Week").tag(TimeFrame.week)
//			Text("This Month").tag(TimeFrame.month)
		}
		.pickerStyle(SegmentedPickerStyle())
		.padding(.horizontal)
    }
}

#Preview {
	@Previewable @State var selectedTimeFrame: TimeFrame = .today
	TimeFramePicker(selectedTimeFrame: $selectedTimeFrame)
}
