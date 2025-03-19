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
			
			Group {
				switch selectedTrackerSection {
				case .add:
					ActivityAddView()
				case .history:
					ActivityHistoryView()
				case .discover:
					ActivityDiscoverView()
				}
			}
		}
		.frame(maxHeight: .infinity, alignment: .top)
	}
}

#Preview {
	@Previewable @State var standard = Stanford360Standard()
	@Previewable @State var activityManager = ActivityManager()
	
    ActivityTabView()
		.environment(standard)
		.environment(activityManager)
}
