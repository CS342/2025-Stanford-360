//
//  ShareSheet.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/13/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
	let activityItems: [Any]
	
	func makeUIViewController(context: Context) -> UIActivityViewController {
		UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
	}
	
	func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) { }
}

#Preview {
    ShareSheet(activityItems: [])
}
