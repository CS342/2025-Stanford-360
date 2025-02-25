//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProteinTrackerView: View {
    @State private var isCardAnimating = false
    @State private var isProgressAnimating = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    headerView()
                    DailyProgressView(currentValue:45, maxValue: 60)
                        .frame(height: 250)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Spacer()
                    mealsCardView()
                }
                .padding()
            }
            .navigationBarHidden(true)
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
    
    private func headerView() -> some View {
        Text("🍗 Protein Tracker")
            .font(.system(size: 34, weight: .bold, design: .rounded))
            .foregroundColor(.primary)
            .padding(.top)
    }
    
    private func mealsHeaderView() -> some View {
        HStack {
            Text("Daily Meals")
                .font(.title2.bold())
            Spacer()
            Text("2 of 3 Meals") // record meal intake->recommend 6 meals a day
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.blue.opacity(0.1))
                )
        }
    }
    
    private func mealsList() -> some View {
        VStack(spacing: 16) {
            mealRowView(
                mealName: "Breakfast",
                protein: "25g",
                time: "8:00 AM",
                isCompleted: true
            )
            
            Divider()
            
            mealRowView(
                mealName: "Lunch",
                protein: "35g",
                time: "12:30 PM",
                isCompleted: true
            )
            
            Divider()
            
            mealRowView(
                mealName: "Dinner",
                protein: "40g",
                time: "7:00 PM",
                isCompleted: false
            )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
        .shadow(color: Color.black.opacity(0.05), radius: 10)
    }
    
    private func mealsCardView() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            mealsHeaderView()
            mealsList()
                .opacity(isCardAnimating ? 1 : 0)
                .offset(y: isCardAnimating ? 0 : 50)
                .onAppear {
                    withAnimation(.spring(response: 0.8)) {
                        isCardAnimating = true
                    }
                }
        }
    }
    
    private func mealRowView(mealName: String, protein: String, time: String, isCompleted: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(mealName)
                    .font(.headline)
                Text(protein)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(time)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.trailing, 8)
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(isCompleted ? .blue : .gray.opacity(0.3))
                .symbolEffect(.bounce, value: isCompleted)
        }
        .contentShape(Rectangle())
    }
}

#if DEBUG
#Preview {
    ProteinTrackerView()
}
#endif
