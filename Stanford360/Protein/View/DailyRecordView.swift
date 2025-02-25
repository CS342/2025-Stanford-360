//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProteinProgressView: View {
    let currentValue: Int
    let maxValue: Int
    
    // Animation states
    @State private var isAnimating = false
    @State private var showText = false
    
    var progress: Double {
        min(Double(currentValue) / Double(maxValue), 1.0)
    }
    
    var body: some View {
        ZStack {
            backgroundRing()
            progressRing()
            glowEffect()
            infoText()
        }
        .onAppear {
            animateContent()
        }
    }
    
    private func backgroundRing() -> some View {
        Circle()
            .stroke(style: StrokeStyle(
                lineWidth: 35,
                lineCap: .round
            ))
            .opacity(0.15)
            .foregroundStyle(
                LinearGradient(
                    colors: [.blue.opacity(0.5), .blue.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
    
    private func progressRing() -> some View {
        Circle()
            .trim(from: 0.0, to: isAnimating ? CGFloat(progress) : 0)
            .stroke(style: StrokeStyle(
                lineWidth: 35,
                lineCap: .round
            ))
            .foregroundStyle(
                LinearGradient(
                    colors: [.blue, .blue.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .rotationEffect(Angle(degrees: 270))
            .animation(.spring(response: 1.0), value: isAnimating)
    }
    
    private func glowEffect() -> some View {
        Circle()
            .trim(from: 0.0, to: isAnimating ? CGFloat(progress) : 0)
            .stroke(style: StrokeStyle(
                lineWidth: 35,
                lineCap: .round
            ))
            .foregroundStyle(.blue)
            .rotationEffect(Angle(degrees: 270))
            .blur(radius: 15)
            .opacity(0.3)
            .animation(.spring(response: 1.0), value: isAnimating)
    }
    
    private func infoText() -> some View {
        VStack(spacing: 8) {
            Text("\(currentValue)")
                .font(.system(size: 65, weight: .bold, design: .rounded))
                .opacity(showText ? 1 : 0)
                .scaleEffect(showText ? 1 : 0.5)
            
            Text("protein")
                .font(.system(.title3, design: .rounded))
                .foregroundStyle(.secondary)
                .opacity(showText ? 1 : 0)
                .scaleEffect(showText ? 1 : 0.5)
            
            Text("Goal: \(maxValue) g")
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(.secondary)
                .padding(.top, 4)
                .opacity(showText ? 1 : 0)
                .scaleEffect(showText ? 1 : 0.5)
        }
    }
    
    private func animateContent() {
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
            showText = true
        }
        withAnimation(.easeInOut(duration: 1.0)) {
            isAnimating = true
        }
    }
}

#if DEBUG
#Preview {
    ProteinProgressView(currentValue: 45, maxValue: 60)
        .frame(height: 300)
        .padding()
}
#endif
