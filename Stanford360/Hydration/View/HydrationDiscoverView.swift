//
//  HydrationDiscoverView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/10/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct HydrationDiscoverView: View {
    var body: some View {
        VStack {
            Image("HydrationDiscover")
                .resizable()
                .scaledToFit()
                .frame(width: 350, height: 350)
                .scaleEffect(1.3)
                .padding()
                .accessibilityLabel("Hydration Recommendations")
        }
    }
}

#Preview {
    HydrationDiscoverView()
}
