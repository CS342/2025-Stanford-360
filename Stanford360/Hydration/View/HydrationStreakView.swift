//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

/*
import SwiftUI

struct HydrationStreakView: View {
    @Environment(HydrationManager.self) private var hydrationManager
    @State private var streakJustUpdated = false

    var body: some View {
        let currentStreak = hydrationManager.streak
        
        return Group {
            if currentStreak > 0 {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .accessibilityLabel("Streak icon")
                    Text("\(currentStreak) Day Streak")
                        .font(.headline)
                        .foregroundColor(.orange)
                        .scaleEffect(streakJustUpdated ? 1.2 : 1.0)
                        .opacity(streakJustUpdated ? 1.0 : 0.8)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: streakJustUpdated)
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.2))
                        .shadow(radius: 2)
                )
                .transition(.scale)
                .accessibilityIdentifier("streakLabel")
            } else {
                EmptyView()
            }
        }
    }
}
*/
