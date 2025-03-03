//
//  LogWeightView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/3/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct LogWeightView: View {
	@State private var showWeightSheet = false
	@State private var weight: String = ""
	
	var body: some View {
		Section {
			Button("Log Weight") {
				showWeightSheet.toggle()
			}
			.frame(maxWidth: .infinity, alignment: .center)
		}
		.sheet(isPresented: $showWeightSheet) {
			LogWeightSheet(weight: $weight, showSheet: $showWeightSheet)
		}
	}
}

#Preview {
	LogWeightView()
}
