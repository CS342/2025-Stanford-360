//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct MilestoneContentView: View {
    let message: String
    let isSpecialMilestone: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "star.fill")
                .font(.system(size: 30))
                .foregroundColor(.yellow.opacity(0.8))
                .shadow(color: .yellow.opacity(0.8), radius: 5, x: 0, y: 0)
                .accessibilityLabel("Achievement Star")
            
            Text(message)
                .foregroundColor(.white)
                .font(.custom("SF Pro Rounded-Bold", size: 18))
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .shadow(color: .black.opacity(0.8), radius: 4, x: 2, y: 2)
        }
        .padding()
        .background(getMilestoneShape(isSpecial: isSpecialMilestone))
    }
    
    @ViewBuilder
    private func getMilestoneShape(isSpecial: Bool) -> some View {
        let colors = isSpecial
            ? [Color.orange.opacity(0.8), Color.pink.opacity(0.7)]
            : [Color.blue.opacity(0.8), Color.mint.opacity(0.7)]

        RoundedRectangle(cornerRadius: 15)
            .fill(
                LinearGradient(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .shadow(color: (isSpecial ? Color.orange : Color.blue).opacity(1.0), radius: 10, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.white.opacity(0.4), lineWidth: 1.5)
            )
    }
}
