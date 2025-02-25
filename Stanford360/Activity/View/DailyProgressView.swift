//
//  DailyProgressView.swift
//  Stanford360
//
//  Created by Elsa Bismuth on 13/02/2025.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT

import SwiftUI

struct DailyProgressView: View {
    let activeMinutes: Int
    private let goalMinutes = 60
    
    var progress: Double {
        min(Double(activeMinutes) / Double(goalMinutes), 1.0)
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20)
                .opacity(0.3)
                .foregroundColor(.blue)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(progress))
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                .foregroundColor(.blue)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)
            
            VStack {
                Text("\(activeMinutes)")
                    .font(.system(size: 50, weight: .bold, design: .rounded))
                Text("minutes")
                    .font(.headline)
            }
        }
    }
}

#Preview {
    DailyProgressView(activeMinutes: 45)  // Shows progress towards 60-minute goal
}
