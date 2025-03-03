//
//  ActivityRecsSheet.swift
//  Stanford360
//
//  Created by Elsa Bismuth on 03/03/2025.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT

import SwiftUI

struct ActivityRecsSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                headerView
                Image("activityRecs") // Replace with your image name
                    .resizable()
                    .scaledToFit()
                    .frame(width: 350, height: 350)
                    .padding()
                    .accessibilityLabel("Activity Recommendations")
                closeButton
            }
            .navigationTitle("Activity Recommendations")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // Styled header view
    private var headerView: some View {
        VStack(spacing: 8) {
//            Text("Activity Recommendations")
//                .font(.system(size: 28, weight: .bold))
//                .multilineTextAlignment(.center)
//                .padding(.top, 8)
//            
            Text("Choose activities from each category for a balanced routine")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 12)
        }
    }
    
    // Styled close button
    private var closeButton: some View {
        Button(action: {
            dismiss()
        }) {
            Text("Close")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(width: 200, height: 50)
                .background(Color.blue)
                .cornerRadius(25)
                .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
        }
        .padding(.bottom, 16)
    }
}

#Preview {
    ActivityRecsSheet()
}
