//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Charts
import SwiftUI

// MARK: - Data Models
struct DailyHydrationData: Identifiable {
    let id = UUID()
    let dayName: String
    let intakeOz: Double
}

struct WeeklyHydrationInMonthData: Identifiable {
    let id = UUID()
    let weekName: String
    let intakeOz: Double
}

// MARK: - Sample Data
let sampleDayByDayData: [DailyHydrationData] = [
    DailyHydrationData(dayName: "Sun", intakeOz: 30),
    DailyHydrationData(dayName: "Mon", intakeOz: 45),
    DailyHydrationData(dayName: "Tue", intakeOz: 60),
    DailyHydrationData(dayName: "Wed", intakeOz: 70),
    DailyHydrationData(dayName: "Thu", intakeOz: 50),
    DailyHydrationData(dayName: "Fri", intakeOz: 42),
    DailyHydrationData(dayName: "Sat", intakeOz: 86)
]

let sampleWeeksInMonth: [WeeklyHydrationInMonthData] = [
    WeeklyHydrationInMonthData(weekName: "Week 1", intakeOz: 40),
    WeeklyHydrationInMonthData(weekName: "Week 2", intakeOz: 70),
    WeeklyHydrationInMonthData(weekName: "Week 3", intakeOz: 55),
    WeeklyHydrationInMonthData(weekName: "Week 4", intakeOz: 65)
]

extension HydrationTrackerView {
    // MARK: - Header View
    func headerView() -> some View {
        Text("💧 Hydration Tracker")
            .font(.largeTitle)
            .bold()
            .foregroundColor(.blue)
            .accessibilityLabel("Hydration Tracker Header")
    }

    // MARK: - "Today" Tab Content
    func todayView() -> some View {
        VStack(spacing: 20) {
            progressBar()
            streakDisplay()
            presetButtonsGrid()
            logButton()
            errorDisplay()
            suggestionDisplay()
            milestoneMessageView()
        }
    }

    // MARK: - "This Week" Placeholder
    func monthlyViewPlaceholder() -> some View {
        VStack(alignment: .leading) {
            Text("Monthly Hydration")
                .font(.headline)
                .foregroundColor(.blue)
            
            Chart {
                ForEach(sampleWeeksInMonth) { data in
                    LineMark(
                        x: .value("Week", data.weekName),
                        y: .value("Intake", data.intakeOz)
                    )
                    .symbol {
                        Circle().fill(.orange).frame(width: 8, height: 8)
                    }
                    .foregroundStyle(.orange)
                }

                // Red dashed line for 60 oz goal
                RuleMark(y: .value("Goal", 60))
                    .foregroundStyle(.red)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    .annotation(position: .top, alignment: .leading) {
                        Text("Goal").font(.caption).foregroundColor(.red)
                    }
            }
            .chartYScale(domain: 0...100)
            .frame(height: 200)
        }
        .padding()
    }

    // MARK: - "This Month" Placeholder
    func weeklyViewPlaceholder() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Hydration")
                .font(.headline)
                .foregroundColor(.blue)

            Chart {
                ForEach(sampleDayByDayData) { data in
                    BarMark(
                        x: .value("Day", data.dayName),
                        y: .value("Intake", data.intakeOz)
                    )
                    .foregroundStyle(Color.blue.gradient)
                }

                // Goal line
                RuleMark(y: .value("Goal", 60))
                    .foregroundStyle(.red)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    .annotation(position: .top, alignment: .leading) {
                        Text("Goal")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
            }
            .frame(height: 200)
        }
        .padding()
    }

    // MARK: - Circular Progress Bar
    func progressBar() -> some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 10)
                .opacity(0.3)
                .foregroundColor(.gray)
            Circle()
                .trim(from: 0.0, to: min(CGFloat(totalIntake) / 60.0, 1.0))
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 1.0), value: totalIntake)

            Text("\(Int(totalIntake)) / 60 oz")
                .font(.title3)
                .foregroundColor(.blue)
                .accessibilityIdentifier("progressBarLabel")
        }
        .frame(width: 140, height: 140)
    }

    // MARK: - Streak Display
    func streakDisplay() -> some View {
        VStack {
            if let streak = streak, streak > 0 {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .accessibilityLabel("Streak icon")
                    Text("\(streak) Day Streak")
                        .font(.headline)
                        .foregroundColor(.orange)
                        .scaleEffect(streakJustUpdated ? 1.2 : 1.0)
                        .opacity(streakJustUpdated ? 1.0 : 0.8)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: streakJustUpdated)
                }
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.orange.opacity(0.2)).shadow(radius: 2))
                .transition(.scale)
                .accessibilityIdentifier("streakLabel")
            } else {
                EmptyView()
            }
        }
    }

    // MARK: - Preset Buttons Grid
    func presetButtonsGrid() -> some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(presetAmounts, id: \.amount) { item in
                VStack(spacing: 6) {
                    Image(item.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(
                            width: [16, 20, 32].contains(item.amount) ? 40 : 30,
                            height: [16, 20, 32].contains(item.amount) ? 40 : 30
                        )
                        .clipped()
                        .accessibilityLabel("\(Int(item.amount)) oz water")

                    Text("\(Int(item.amount)) oz")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                .frame(width: 65, height: 65)
                .padding()
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 12).fill(Color.white)
                        if selectedAmount == item.amount {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue, lineWidth: 3)
                        }
                    }
                )
                .shadow(radius: 2)
                .onTapGesture {
                    selectedAmount = item.amount
                    errorMessage = nil
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Log Button
    func logButton() -> some View {
        Button(action: {
            guard let selected = selectedAmount else {
                errorMessage = "❌ Please select an amount first."
                return
            }
            intakeAmount = String(selected)
            Task {
                await logWaterIntake()
            }
        }) {
            Text("Log Water Intake")
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [
                            Color.blue,
                            Color.blue.opacity(0.8)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(radius: 3)
        }
        .padding(.horizontal)
        .accessibilityIdentifier("logWaterIntakeButton")
        .accessibilityLabel("Log your water intake")
    }

    // MARK: - Error Display
    func errorDisplay() -> some View {
        Group {
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.subheadline)
                    .accessibilityIdentifier("errorMessageLabel")
            }
        }
    }

    // MARK: - Milestone Message View
    func milestoneMessageView() -> some View {
        if let milestoneMessage = milestoneMessage {
            return AnyView(
                Text(milestoneMessage)
                    .foregroundColor(isSpecialMilestone ? .orange : .blue)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white).shadow(radius: 2))
                    .transition(.scale)
                    .accessibilityIdentifier("milestoneMessageLabel")
            )
        } else {
            return AnyView(EmptyView())
        }
    }

    // MARK: - Goal Suggestion Display
    func suggestionDisplay() -> some View {
        if totalIntake < 60 {
            return AnyView(
                Text("You need \(String(format: "%.1f", 60 - totalIntake)) oz more to reach your goal!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .accessibilityIdentifier("suggestionLabel")
            )
        } else {
            return AnyView(
                Text("🎉 Goal Reached! Stay Hydrated! 🎉")
                    .font(.subheadline)
                    .foregroundColor(.green)
                    .bold()
                    .accessibilityIdentifier("goalReachedLabel")
            )
        }
    }
}
