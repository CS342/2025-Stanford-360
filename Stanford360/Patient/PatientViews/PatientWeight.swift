//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
//  PatientWeight.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 2/10/25.
//

import SwiftUI

struct PatientWeight: View {
	@Environment(PatientManager.self) private var patientManager
	
	@Binding var isEditing: Bool
	@Binding var weightText: Double
	
    var body: some View {
		HStack {
			Text("Weight:")
			if isEditing {
				TextField("Enter weight", value: $weightText, format: .number.precision(.significantDigits(2)))
					.multilineTextAlignment(.trailing)
					.keyboardType(.decimalPad)
					.textFieldStyle(RoundedBorderTextFieldStyle())
			} else {
				Text("\(weightText)")
			}
		}
		.padding()
    }
}

#Preview {
	@Previewable @State var isEditing: Bool = false
	@Previewable @State var weightText: Double = 0
	PatientWeight(isEditing: $isEditing, weightText: $weightText)
}
