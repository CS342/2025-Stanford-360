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
	
	private let ringWidth: CGFloat = 50
	private let iconSize: CGFloat = 30
	
	var body: some View {
		let patient = patientManager.patient
		
		ZStack {
			// activity ring
			PercentageRing(
				ringWidth: ringWidth,
				percent: Double(patient.activityMinutes) / 60 * 100,
				backgroundColor: Color.red.opacity(0.4),
				foregroundColors: [Color.red, Color(red: 0.75, green: 0, blue: 0)],
				icon: Image(systemName: "figure.walk"),
				iconSize: iconSize
			)
			.padding(20)
			.accessibilityLabel("Activity Progress")
			
			// hydration ring
			PercentageRing(
				ringWidth: ringWidth,
				percent: Double(patient.hydrationOunces) / 60 * 100,
				backgroundColor: Color.blue.opacity(0.4),
				foregroundColors: [Color.blue, Color(red: 0, green: 0, blue: 0.75)],
				icon: Image(systemName: "drop.fill"),
				iconSize: iconSize
			)
			.padding(70)
			.accessibilityLabel("Hydration Progress")
			
			// protein ring
			PercentageRing(
				ringWidth: ringWidth,
				percent: Double(patient.proteinGrams) / 60 * 100,
				backgroundColor: Color.green.opacity(0.4),
				foregroundColors: [Color.green, Color(red: 0, green: 0.75, blue: 0)],
				icon: Image(systemName: "fork.knife"),
				iconSize: iconSize
			)
			.padding(120)
			.accessibilityLabel("Protein Progress")
		}
	}
}

#Preview {
	@Previewable @State var patientManager = PatientManager(patient: Patient(activityMinutes: 30, hydrationOunces: 40, proteinGrams: 10))
	
	ProgressRings()
		.environment(patientManager)
}
