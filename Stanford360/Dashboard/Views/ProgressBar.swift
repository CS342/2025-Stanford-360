//
//  ProgressBar.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/1/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProgressBar: View {
	let progress: CGFloat
	let color: Color
	
	var body: some View {
		ProgressView(value: min(progress, 1))
			.tint(color)
			.background(Color.progressBackground)
	}
}

#Preview {
	ProgressBar(progress: 0.5, color: .red)
}
