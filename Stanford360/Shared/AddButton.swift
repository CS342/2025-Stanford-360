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

struct AddButton: View {
	@Binding var showingAddItem: Bool
	var imageAccessibilityLabel: String
	
	var body: some View {
		VStack {
			Spacer()
			HStack {
				Spacer()
				Button(action: { showingAddItem = true }) {
					Image(systemName: "plus.circle.fill")
						.font(.system(size: 56))
						.foregroundColor(.blue)
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
	AddButton(showingAddItem: $showingAddItem, imageAccessibilityLabel: "Add Activity Button")
}
