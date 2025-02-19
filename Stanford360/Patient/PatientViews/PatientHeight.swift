//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
//  PatientHeight.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 2/10/25.
//

import SwiftUI

struct PatientHeight: View {
	@Environment(PatientManager.self) private var patientManager
	
	@Binding var isEditing: Bool
	@Binding var heightText: Double
	
    var body: some View {
		HStack {
			Text("Height:")
			if isEditing {
				TextField("Enter height", value: $heightText, format: .number.precision(.significantDigits(2)))
					.multilineTextAlignment(.trailing)
					.keyboardType(.decimalPad)
					.textFieldStyle(RoundedBorderTextFieldStyle())
			} else {
				Text("\(heightText)")
			}
		}
		.padding()
    }
}

#Preview {
	@Previewable @State var isEditing: Bool = false
	@Previewable @State var heightText: Double = 0
	PatientHeight(isEditing: $isEditing, heightText: $heightText)
}
