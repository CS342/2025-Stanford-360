//
//  AddButton.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/2/25.
//
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct IconButton: View {
	@Binding var showingAddItem: Bool
	var imageName: String
	var imageAccessibilityLabel: String
	var color: Color
	
	var body: some View {
		VStack {
			Spacer()
			HStack {
				Spacer()
				Button(action: { showingAddItem = true }) {
					Image(systemName: imageName)
						.font(.system(size: 56))
						.foregroundColor(color)
						.shadow(radius: 3)
						.background(Circle().fill(.white))
						.accessibilityLabel(imageAccessibilityLabel)
				}
				.padding([.trailing, .bottom], 25)
			}
		}
	}
}

#Preview {
	@Previewable @State var showingAddItem: Bool = false
	IconButton(showingAddItem: $showingAddItem, imageName: "plus.circle.fill", imageAccessibilityLabel: "Add Activity Button", color: .blue)
}
