//
//  ActivityTabView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/10/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct ActivityTabView: View {
	@State private var selectedTrackerSection: TrackerSection = .add
	
    var body: some View {
		VStack {
			TrackerSegmentedPicker(selectedTrackerSection: $selectedTrackerSection)
			
			TabView(selection: $selectedTrackerSection) {
				ActivityAddView().tag(TrackerSection.add)
				ActivityHistoryView().tag(TrackerSection.history)
				ActivityDiscoverView().tag(TrackerSection.discover)
			}
			.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
		}
    }
}

#Preview {
	@Previewable @State var standard = Stanford360Standard()
	@Previewable @State var activityManager = ActivityManager(activities: activitiesData)
	
    ActivityTabView()
		.environment(standard)
		.environment(activityManager)
}
