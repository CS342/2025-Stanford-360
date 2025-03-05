//
//  LogWeightSheet.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/3/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct LogWeightSheet: View {
	@Environment(PatientManager.self) var patientManager
	
	@Binding var weight: String
	@Binding var showSheet: Bool
	
	var body: some View {
		NavigationView {
			VStack {
				TextField("Weight (lbs)", text: $weight)
					.keyboardType(.numberPad)
					.textFieldStyle(RoundedBorderTextFieldStyle())
					.padding()
				
				Button("Save") {
                    if Double(weight) != nil {
						patientManager.updateWeight(Double(weight) ?? 0)
					}
					weight = ""
					showSheet = false
				}
				.frame(maxWidth: .infinity)
				.padding()
				.background(.blue)
				.foregroundColor(.white)
				.cornerRadius(10)
				
				Spacer()
			}
			.padding()
			.navigationTitle("Log Weight")
			.navigationBarTitleDisplayMode(.inline)
			.navigationBarItems(trailing: Button("Cancel") {
				showSheet = false
			})
		}
	}
}

#Preview {
	@Previewable @State var patientManager = PatientManager()
	@Previewable @State var weight: String = "180"
	@Previewable @State var showSheet: Bool = true
	LogWeightSheet(weight: $weight, showSheet: $showSheet)
		.environment(patientManager)
}
