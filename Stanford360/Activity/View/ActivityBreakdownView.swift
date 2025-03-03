//
//  ActivityBreakdownView.swift
//  Stanford360
//
//  Created by Elsa Bismuth on 13/02/2025.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT

import SwiftUI

struct ActivityBreakdownView: View {
    let activities: [Activity]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 5) {
                Text("Activity Breakdown")
                    .font(.headline)
                    .padding(.horizontal)
                
                ForEach(calculateBreakdown().sorted(by: { $0.value > $1.value }), id: \.key) { activity, minutes in
                    HStack {
                        Text(activity)
                            .font(.subheadline)
                        Spacer()
                        Text("\(minutes) min")
                            .font(.subheadline.bold())
                            .foregroundStyle(.blue)
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
            .padding(.horizontal)
            .padding(.top, 10)
        }
    }
    
    private func calculateBreakdown() -> [String: Int] {
        var breakdown: [String: Int] = [:]
        for activity in activities {
            breakdown[activity.activityType, default: 0] += activity.activeMinutes
        }
        return breakdown
    }
}

#Preview {
    let sampleActivities: [Activity] = [
        Activity(
            date: Date(),
            steps: 8000,
            activeMinutes: 45,
            activityType: "Running"
        ),
        {
            guard let date = Calendar.current.date(byAdding: .day, value: -1, to: Date()) else {
                fatalError("Failed to generate date")
            }
            return Activity(
                date: date,
                steps: 6000,
                activeMinutes: 30,
                activityType: "Walking"
            )
        }(),
        {
            guard let date = Calendar.current.date(byAdding: .day, value: -3, to: Date()) else {
                fatalError("Failed to generate date")
            }
            return Activity(
                date: date,
                steps: 7500,
                activeMinutes: 40,
                activityType: "Soccer"
            )
        }()
    ]
    
    return ActivityBreakdownView(activities: sampleActivities)
}
