//
//  LineChartContent.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/2/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Charts
import Foundation
import SwiftUI

func goalLine() -> some ChartContent {
	RuleMark(
		y: .value("Goal", 60)
	)
	.foregroundStyle(.red)
	.lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
	.annotation(position: .leading) {
		Text("Goal")
			.font(.caption)
			.foregroundStyle(.red)
	}
}
