//
//  ActivityDiscoverView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/10/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct ActivityDiscoverView: View {
    var body: some View {
		VStack {
			Image("activityRecs")
				.resizable()
				.scaledToFit()
				.frame(width: 350, height: 350)
				.padding()
				.accessibilityLabel("Activity Recommendations")
		}
    }
}

#Preview {
    ActivityDiscoverView()
}
