//
//  ProgressCard.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/1/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProgressCard: View {
	let title: String
	let progress: CGFloat
	let color: Color
	
	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			HStack {
				Text(title)
					.font(.system(size: 17))
					.foregroundColor(.textSecondary)
				
				Spacer()
				
				HStack(alignment: .firstTextBaseline) {
					Text("\(progress, specifier: "%.f")")
						.font(.system(size: 22, weight: .bold))
						.foregroundColor(color)
					
					Text("/ 60")
						.font(.system(size: 22))
						.foregroundColor(.textTertiary)
				}
			}
			
			ProgressBar(progress: progress / 100, color: color)
		}
		.padding(16)
		.background(Color.cardBackground)
		.cornerRadius(15)
		.shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 4)
	}
}

#Preview {
	ProgressCard(
		title: "Activity",
		progress: 10,
		color: .red
	)
}
