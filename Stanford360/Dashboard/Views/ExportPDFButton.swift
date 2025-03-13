//
//  ExportPDFButton.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/12/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct ExportPDFButton: View {
	@Binding var showingSheet: Bool
	
    var body: some View {
		Button(action: { showingSheet = true }) {
			Text("View as PDF")
			Image(systemName: "eye")
				.accessibilityLabel(Text("View as PDF Button"))
		}
    }
}

#Preview {
	@Previewable @State var showingSheet: Bool = false
	ExportPDFButton(showingSheet: $showingSheet)
}
