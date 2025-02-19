//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
//  CircleImage.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 2/6/25.
//

import SwiftUI

struct CircleImage: View {
	var text: String
	
	var body: some View {
		Circle()
			.fill(.quaternary)
			.overlay {
				ZStack {
					Text(text)
						.font(.system(size: 100))
						.fontWeight(.light)
					Circle()
						.stroke(.white, lineWidth: 4)
				}
			}
			.shadow(radius: 7)
			.frame(maxWidth: 200)
   }
}

#Preview {
	CircleImage(text: "JD")
}
