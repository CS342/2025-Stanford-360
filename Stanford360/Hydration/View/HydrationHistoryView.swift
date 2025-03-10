//
//  HydrationHistoryView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/10/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct HydrationHistoryView: View {
	@Environment(HydrationManager.self) private var hydrationManager
	
	var body: some View {
		let hydration = hydrationManager.hydration
		let reverseSortedHydration = hydrationManager.reverseSortHydrationByDate(hydration)
		
		if hydration.isEmpty {
			// todo - decompose into "empty state" component
			List {
				Text("No hydration logged today")
					.foregroundColor(.gray)
					.padding()
			}
			.listStyle(PlainListStyle())
		} else {
			List {
				ForEach(reverseSortedHydration) { hydrationLog in
					HydrationCardView(hydrationLog: hydrationLog)
						.simultaneousGesture(
							DragGesture(minimumDistance: 5)
								.onChanged { value in
									let isHorizontalDrag = abs(value.translation.width) > abs(value.translation.height)
									let isQuickSwipe = abs(value.translation.width) < 20
									
									// If it's a quick, short horizontal swipe, let it through
									// as it's likely attempting to access the swipe actions
									if isHorizontalDrag && !isQuickSwipe {
										// Consume the gesture to prevent TabView swiping
									}
								}
						)
				}
			}
			.listStyle(PlainListStyle())
		}
	}
}

#Preview {
	@Previewable @State var standard = Stanford360Standard()
	@Previewable @State var hydrationManager = HydrationManager()
	HydrationHistoryView()
		.environment(standard)
		.environment(hydrationManager)
}
