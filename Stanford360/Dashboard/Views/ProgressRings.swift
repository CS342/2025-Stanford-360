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
				ringWidth: ringWidth,
				percent: Double(patient.activityMinutes) / 60 * 100,
				backgroundColor: .activityColor.opacity(0.4),
				foregroundColors: [.activityColor, .red],
				icon: Image(systemName: "figure.walk"),
				iconSize: iconSize + 2
			)
			.frame(width: activityRingSize, height: activityRingSize)
			.accessibilityLabel("Activity Progress")
			
			// Hydration Ring
			let hydrationRingSize = baseRingSize + (ringSpacing + ringWidth) * 2
			PercentageRing(
				ringWidth: ringWidth,
				percent: Double(patient.hydrationOunces) / 60 * 100,
				backgroundColor: .hydrationColor.opacity(0.4),
				foregroundColors: [.hydrationColor, .blue],
				icon: Image(systemName: "drop.fill"),
				iconSize: iconSize
			)
			.frame(width: hydrationRingSize, height: hydrationRingSize)
			.accessibilityLabel("Hydration Progress")
			
			// Protein Ring
			PercentageRing(
				ringWidth: ringWidth,
				percent: Double(patient.proteinGrams) / 60 * 100,
				backgroundColor: .proteinColor.opacity(0.4),
				foregroundColors: [.proteinColor, .green],
				icon: Image(systemName: "fork.knife"),
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
