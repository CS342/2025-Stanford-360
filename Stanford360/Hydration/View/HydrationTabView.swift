//
//  HydrationTabView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/10/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct HydrationTabView: View {
	@State private var selectedTrackerSection: TrackerSection = .add
	
	var body: some View {
		VStack {
			TrackerSegmentedPicker(selectedTrackerSection: $selectedTrackerSection)
			
			TabView(selection: $selectedTrackerSection) {
				HydrationAddView().tag(TrackerSection.add)
				HydrationHistoryView().tag(TrackerSection.history)
				HydrationDiscoverView().tag(TrackerSection.discover)
			}
			.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
			
			if selectedTrackerSection == .add {
				HydrationControlPanel()
			}
		}
	}
}

#Preview {
	@Previewable @State var standard = Stanford360Standard()
	@Previewable @State var hydrationManager = HydrationManager(hydration: [])
	
	HydrationTabView()
		.environment(standard)
		.environment(hydrationManager)
}
