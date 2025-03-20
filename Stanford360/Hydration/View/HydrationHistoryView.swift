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
		let hydrationByDate = hydrationManager.hydrationByDate
		let dates = hydrationByDate.keys.sorted(by: >)
		
		if hydrationManager.hydration.isEmpty {
			// todo - decompose into "empty state" component
			List {
				Text("No hydration logged")
					.foregroundColor(.gray)
					.padding()
                    .accessibilityIdentifier("noHydrationLogs")
			}
			.listStyle(PlainListStyle())
		} else {
			List {
				ForEach(dates, id: \.self) { date in
					Section(header: Text(date.formattedRelative())) {
						ForEach(hydrationManager.reverseSortHydrationByDate(hydrationByDate[date] ?? [])) { hydrationLog in
							HydrationCardView(hydrationLog: hydrationLog)
								.listRowSeparator(.hidden)
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
	@Previewable @State var hydrationManager = HydrationManager()
	HydrationHistoryView()
		.environment(standard)
		.environment(hydrationManager)
}
