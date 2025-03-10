//
//  HydrationCardView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/10/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

// TODO - align with dashboard cards + add swipe actions	// swiftlint:disable:this todo
struct HydrationCardView: View {
	let hydrationLog: HydrationLog

	var body: some View {
		HStack {
			Text("Water")
				.font(.title3.bold())
			
			Spacer()
			
			// Minutes with emphasis
			Text("\(Int(hydrationLog.hydrationOunces)) oz")
				.font(.title3)
				.foregroundStyle(.blue)
		}
		.padding(16)
		.background(Color.cardBackground)
		.cornerRadius(15)
		.shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 4)
    }
}

#Preview {
	let hydrationLog = HydrationLog(hydrationOunces: 32, timestamp: Date(), id: "sample-id")
	HydrationCardView(hydrationLog: hydrationLog)
}
