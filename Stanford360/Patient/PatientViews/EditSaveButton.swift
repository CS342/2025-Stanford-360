//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
//  EditSaveButton.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 2/10/25.
//

import SwiftUI

struct EditSaveButton: View {
	@Binding var isEditing: Bool
	
	var onSave: () -> Void
	
    var body: some View {
		Button(isEditing ? "Save" : "Edit") {
			if isEditing {
				onSave()
			}
			
			isEditing.toggle()
		}
		.padding()
		.buttonStyle(.bordered)
    }
}

#Preview {
	@Previewable @State var isEditing: Bool = false
	EditSaveButton(
		isEditing: $isEditing,
//		onEdit: {
//			print("In edit mode")
//		},
		onSave: {
			print("In save mode")
		}
	)
}
