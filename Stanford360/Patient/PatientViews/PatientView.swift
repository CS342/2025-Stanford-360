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

struct PatientView: View {
    var body: some View {
		VStack {
			CircleImage(text: "JD")
				.offset(y: -130)
				.padding(.bottom, -130)
				.accessibilityLabel(Text("JD"))
			
			Text("John Doe")
				.font(.largeTitle)
		}
    }
}

#Preview {
    PatientView()
}
