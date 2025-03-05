//
//  ProgressRings.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 2/26/25.
//	Inspired by Frank Gia https://medium.com/@frankjia/creating-activity-rings-in-swiftui-11ef7d336676
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProgressRings: View {
	@Environment(PatientManager.self) private var patientManager
	
	private let ringWidth: CGFloat = 35
	private let ringSpacing: CGFloat = 5
	private let baseRingSize: CGFloat = 120
	private let iconSize: CGFloat = 16
	
	var body: some View {
		let patient = patientManager.patient
		
		ZStack {
			// Activity Ring
			let activityRingSize = baseRingSize + (ringSpacing + ringWidth) * 4
			PercentageRing(
				currentValue: patient.activityMinutes,
				maxValue: 60,
				iconName: "figure.walk",
				ringWidth: ringWidth,
				backgroundColor: .activityColorBackground,
				foregroundColors: [.activityColor, .activityColorGradient],
				iconSize: iconSize + 2
			)
			.frame(width: activityRingSize, height: activityRingSize)
			.accessibilityLabel("Activity Progress")
			
			// Hydration Ring
			let hydrationRingSize = baseRingSize + (ringSpacing + ringWidth) * 2
			PercentageRing(
				currentValue: Int(patient.hydrationOunces),
				maxValue: 60,
				iconName: "drop.fill",
				ringWidth: ringWidth,
				backgroundColor: .hydrationColorBackground,
				foregroundColors: [.hydrationColor, .hydrationColorGradient],
				iconSize: iconSize
			)
			.frame(width: hydrationRingSize, height: hydrationRingSize)
			.accessibilityLabel("Hydration Progress")
			
			// Protein Ring
			PercentageRing(
				currentValue: Int(patient.proteinGrams),
				maxValue: 60,
				iconName: "fork.knife",
				ringWidth: ringWidth,
				backgroundColor: .proteinColorBackground,
				foregroundColors: [.proteinColor, .proteinColorGradient],
				iconSize: iconSize
			)
			.frame(width: baseRingSize, height: baseRingSize)
			.accessibilityLabel("Protein Progress")
		}
		.padding(.vertical, 30)
		.frame(maxWidth: .infinity)
	}
}

#Preview {
	@Previewable @State var patientManager = PatientManager(patient: Patient(
		weight: Measurement(value: 0, unit: .pounds),
		activityMinutes: 30,
		hydrationOunces: 40,
		proteinGrams: 10
	))
	
	ProgressRings()
		.environment(patientManager)
}
