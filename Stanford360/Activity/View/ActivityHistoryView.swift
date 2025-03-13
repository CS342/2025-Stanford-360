//
//  ActivityHistoryView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/10/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct ActivityHistoryView: View {
	@Environment(ActivityManager.self) private var activityManager
	
	var body: some View {
		let activitiesByDate = activityManager.activitiesByDate
		let dates = activitiesByDate.keys.sorted(by: >)
		
		if activityManager.activities.isEmpty {
			// todo - decompose into "empty state" component
			List {
				Text("No activities logged")
					.foregroundColor(.gray)
					.padding()
			}
			.listStyle(PlainListStyle())
		} else {
			List {
				ForEach(dates, id: \.self) { date in
					Section(header: Text(date.formattedRelative())) {
						ForEach(activityManager.reverseSortActivitiesByDate(activitiesByDate[date] ?? [])) { activity in
							ActivityCardView(activity: activity)
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
				}
			}
			.listStyle(PlainListStyle())
		}
	}
}

#Preview {
	@Previewable @State var standard = Stanford360Standard()
	@Previewable @State var activityManager = ActivityManager()
	ActivityHistoryView()
		.environment(standard)
		.environment(activityManager)
}
