//
//  Colors.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/1/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

extension Color {
	//	would love to potentially make the entire app this background color, but waiting on UI
	// 	unification to decide. keeping here though so the color isn't lost.
	//	static let background = Color(red: 0.97, green: 0.98, blue: 0.98, opacity: 1.0) // #f8f9fa
	
	// 	global app colors
	static let textPrimary = Color(red: 0.18, green: 0.22, blue: 0.28, opacity: 1.0) // #2d3748
	static let textSecondary = Color(red: 0.44, green: 0.50, blue: 0.59, opacity: 1.0) // #718096
	static let textTertiary = Color(red: 0.63, green: 0.69, blue: 0.75, opacity: 1.0) // #A0AEC0
	
	static let activityColor = Color(red: 0.96, green: 0.40, blue: 0.40, opacity: 1.0) // #F56565
	static let activityColorBackground = Color.activityColor.opacity(0.4)
	static let activityColorGradient = Color.red
	static let hydrationColor = Color(red: 0.26, green: 0.60, blue: 0.88, opacity: 1.0) // #4299E1
	static let hydrationColorBackground = Color.hydrationColor.opacity(0.4)
	static let hydrationColorGradient = Color.blue
	static let proteinColor = Color(red: 0.28, green: 0.73, blue: 0.47, opacity: 1.0) // #48BB78
	static let proteinColorBackground = Color.proteinColor.opacity(0.4)
	static let proteinColorGradient = Color.green
	
	//	dashboard view colors
	static let cardBackground = Color.white
	static let progressBackground = Color(red: 0.93, green: 0.95, blue: 0.97, opacity: 1.0) // #EDF2F7
	
}
