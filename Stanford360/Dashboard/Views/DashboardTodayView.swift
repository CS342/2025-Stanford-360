//
//  DashboardTodayView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/2/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct DashboardTodayView: View {
	@Environment(PatientManager.self) private var patientManager
	
    var body: some View {
		let patient = patientManager.patient
		
		ScrollView {
			VStack(alignment: .leading, spacing: 0) {
				ProgressRings()
				
				VStack(spacing: 15) {
					ProgressCard(
						title: "Activity",
						progress: CGFloat(patient.activityMinutes),
						color: .activityColor
					)
					
					ProgressCard(
						title: "Hydration",
						progress: CGFloat(patient.hydrationOunces),
						color: .hydrationColor
					)
					
					ProgressCard(
						title: "Protein",
						progress: CGFloat(patient.proteinGrams),
						color: .proteinColor
					)
				}
				.padding(.horizontal, 20)
			}
		}
    }
}

#Preview {
	@Previewable @State var patientManager = PatientManager(patient: Patient(
		weight: Measurement(value: 0, unit: .pounds),
		activityMinutes: 50,
		hydrationOunces: 40,
		proteinGrams: 10
	))
	
    DashboardTodayView()
		.environment(patientManager)
}
