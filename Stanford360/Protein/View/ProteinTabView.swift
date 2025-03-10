//
//  ProteinTabView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/10/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProteinTabView: View {
	@State private var selectedTrackerSection: TrackerSection = .add
	
    var body: some View {
		VStack {
			TrackerSegmentedPicker(selectedTrackerSection: $selectedTrackerSection)
			
			TabView(selection: $selectedTrackerSection) {
				ProteinAddView().tag(TrackerSection.add)
				ProteinHistoryView().tag(TrackerSection.history)
				ProteinDiscoverView().tag(TrackerSection.discover)
			}
			.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
		}
    }
}

#Preview {
	@Previewable @State var standard = Stanford360Standard()
	@Previewable @State var proteinManager = ProteinManager(meals: mealsData)
	
    ProteinTabView()
		.environment(standard)
		.environment(proteinManager)
}
