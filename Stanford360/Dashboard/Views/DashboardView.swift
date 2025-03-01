//
//  DashboardView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 2/25/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct DashboardView: View {
	@Environment(PatientManager.self) private var patientManager
	
	var body: some View {
		let patient = patientManager.patient
		
		VStack {
			Text("Today's Progress")
				.font(.largeTitle)
				.bold()
				.padding(.bottom, 40)
			
			Text("Activity")
				.font(.title2)
				.fontWeight(.light)
			Text("\(patient.activityMinutes)/60")
				.font(.title)
				.fontWeight(.semibold)
				.foregroundColor(.red)
			Spacer()
			
			Text("Hydration")
				.font(.title2)
				.fontWeight(.light)
			Text("\(patient.hydrationOunces, specifier: "%.2f")/60")
				.font(.title)
				.fontWeight(.semibold)
				.foregroundColor(.blue)
			Spacer()
			
			Text("Protein")
				.font(.title2)
				.fontWeight(.light)
			Text("\(patient.proteinGrams, specifier: "%.2f")/60")
				.font(.title)
				.fontWeight(.semibold)
				.foregroundColor(.green)
			
			ProgressRings()
		}
		.padding(.top, 20)
	}
}

#Preview {
	@Previewable @State var patientManager = PatientManager(patient: Patient(activityMinutes: 50, hydrationOunces: 40, proteinGrams: 10))
	
	DashboardView()
		.environment(patientManager)
}
