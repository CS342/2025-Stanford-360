//
//  ActivityButtonView.swift
//  Stanford360
//
//  Created by Elsa Bismuth on 13/02/2025.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT

import SwiftUI

struct ActivityButtonView: View {
    let activityName: String
    let iconName: String
    @Binding var selectedActivity: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .foregroundColor(.blue) // Change color as needed
                .accessibilityLabel(activityName)

            Text(activityName)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .frame(width: 65, height: 65)
        .padding()
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 12).fill(Color.white)
                if selectedActivity == activityName {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue, lineWidth: 3)
                }
            }
        )
        .shadow(radius: 2)
        .onTapGesture {
            selectedActivity = activityName
        }
    }
}

#Preview {
    @Previewable @State var selectedActivity = "Walking"

    ActivityButtonView(activityName: "Walking", iconName: "figure.walk", selectedActivity: $selectedActivity)
}
