//
//  TrackerSegmentedPicker.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/10/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct TrackerSegmentedPicker: View {
	@Binding var selectedTrackerSection: TrackerSection
	
	var body: some View {
		Picker("Tracker Section", selection: $selectedTrackerSection) {
			ForEach(TrackerSection.allCases, id: \.self) { section in
				Text(section.rawValue.capitalized).tag(section)
			}
		}
		.pickerStyle(SegmentedPickerStyle())
		.padding(.horizontal)
	}
}

#Preview {
	@Previewable @State var selectedTrackerSection: TrackerSection = .add
	TrackerSegmentedPicker(selectedTrackerSection: $selectedTrackerSection)
}
