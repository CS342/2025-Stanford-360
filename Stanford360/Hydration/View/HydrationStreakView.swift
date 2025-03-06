//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct HydrationStreakView: View {
    @Environment(HydrationManager.self) private var hydrationManager
    @State private var isPopping = false
    @State private var showStreak = true

    var body: some View {
        let currentStreak = hydrationManager.streak
        
        return Group {
            if currentStreak > 0 && showStreak {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .accessibilityLabel("Streak icon")
                        .font(.system(size: 14))

                    Text("\(currentStreak) Day Streak")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.orange)
                        .scaleEffect(isPopping ? 1.2 : 1.0)
                        .opacity(isPopping ? 1.0 : 0.8)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isPopping)
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.orange.opacity(0.2))
                        .shadow(radius: 1)
                )
                .transition(.scale)
                .onAppear {
                    handleStreakAnimation()
                }
                .accessibilityIdentifier("streakLabel")
            } else {
                EmptyView()
            }
        }
    }

    // MARK: - Handle Streak Animation
    private func handleStreakAnimation() {
        if hydrationManager.getTodayTotalOunces() >= 60 {
            triggerPopEffect()
            hideStreakAfterDelay()
        }
    }

    // MARK: - Pop Effect Animation
    private func triggerPopEffect() {
        isPopping = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isPopping = false
        }
    }

    // MARK: - Hide Streak After Delay
    private func hideStreakAfterDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            withAnimation {
                showStreak = false
            }
        }
    }
}
