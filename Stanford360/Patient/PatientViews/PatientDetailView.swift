//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
//  PatientView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 2/6/25.
//

import SwiftUI

struct PatientDetailView: View {
	@Environment(PatientManager.self) private var patientManager
	
	@State private var isEditing: Bool = false
	@State private var heightText: Double = 0
	@State private var weightText: Double = 0
	
    var body: some View {
//		if let patient = patientManager.patient {
		VStack {
			CircleImage(text: patientManager.patient?.initials ?? "N/A")
				.offset(y: -130)
				.padding(.bottom, -130)
				.accessibilityLabel(Text(patientManager.patient?.initials ?? "N/A"))
			
			Text(patientManager.patient?.fullName ?? "N/A")
				.font(.largeTitle)
			
			Text(patientManager.patient?.genderIdentity ?? "N/A")
			
			EditSaveButton(isEditing: $isEditing/*, onEdit: onEdit*/, onSave: onSave)
			
			PatientHeight(isEditing: $isEditing, heightText: $heightText)
			PatientWeight(isEditing: $isEditing, weightText: $weightText)
		}
//		} else {
//			Text("Patient not available")
//		}
    }
	
	func onSave() {
		do {
			print("heightText: \(heightText)")
			print("weightText: \(weightText)")
			try patientManager.updatePatientHeight(heightText)
			try patientManager.updatePatientWeight(weightText)
		} catch {
			// todo: alert -> patient isnt available
			print("error")
		}
	}
}

#Preview {
    PatientDetailView()
}
