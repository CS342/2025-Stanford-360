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

extension HydrationTrackerView {
    // MARK: - Hydration Period Picker
    func hydrationPeriodPicker() -> some View {
        Picker("Hydration Period", selection: $selectedTimeFrame) {
            Text("Today").tag(HydrationTimeFrame.today)
            Text("This Week").tag(HydrationTimeFrame.week)
            Text("This Month").tag(HydrationTimeFrame.month)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
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

    // MARK: - Weekly Hydration View
    func weeklyView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Hydration")
                .font(.headline)
                .foregroundColor(.blue)

            weeklyChart()
                .overlay(hoverTooltip())
                .chartOverlay { proxy in
                    chartHoverGesture(proxy: proxy)
                }
        }
        .padding()
    }

    // MARK: - Weekly Chart View
    private func weeklyChart() -> some View {
        Chart {
            ForEach(weeklyData) { data in
                BarMark(
                    x: .value("Day", data.dayName),
                    y: .value("Intake", data.intakeOz)
                )
                .foregroundStyle(Color.blue.gradient)
                .opacity(data.intakeOz > 0 ? 1 : 0)
            }

            // Goal line
            goalLine()
        }
        .chartXAxis {
            AxisMarks(values: weeklyData.map { $0.dayName })
        }
        .chartYScale(domain: 0...maxWeeklyIntake)
        .frame(height: 200)
    }

    // MARK: - Chart Hover Gesture
    private func chartHoverGesture(proxy: ChartProxy) -> some View {
        Color.clear
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let location = value.location
                        if let closestData = findClosestWeeklyData(to: location, in: proxy) {
                            selectedDate = closestData.dayName
                            selectedIntake = closestData.intakeOz
                            selectedPosition = location
                        }
                    }
                    .onEnded { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            selectedDate = nil
                            selectedIntake = nil
                            selectedPosition = nil
                        }
                    }
            )
    }

    // MARK: - Find Closest Weekly Data Point
    private func findClosestWeeklyData(to location: CGPoint, in proxy: ChartProxy) -> DailyHydrationData? {
        guard !weeklyData.isEmpty else {
            return nil
        }

        if let dayName = proxy.value(atX: location.x, as: String.self) {
            return weeklyData.first(where: { $0.dayName == dayName })
        }

        return nil
    }

    // MARK: - Monthly Hydration View
    func monthlyView() -> some View {
        VStack(alignment: .leading) {
            Text("Monthly Hydration")
                .font(.headline)
                .foregroundColor(.blue)

            chartView()
                .overlay(hoverTooltip())
                .chartOverlay { proxy in
                    Color.clear
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let location = value.location
                                    if let closestData = findClosestData(to: location, in: proxy) {
                                        selectedDate = closestData.dayName
                                        selectedIntake = closestData.intakeOz
                                        selectedPosition = location
                                    }
                                }
                                .onEnded { _ in
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        selectedDate = nil
                                        selectedIntake = nil
                                        selectedPosition = nil
                                    }
                                }
                        )
                }
        }
        .padding()
    }

    // MARK: - Chart View
    private func chartView() -> some View {
        Chart {
            ForEach(monthlyData, id: \.id) { data in
                LineMark(
                    x: .value("Date", data.dayName),
                    y: .value("Intake", data.intakeOz)
                )
                .interpolationMethod(.monotone)
                .foregroundStyle(.blue.gradient)
            }

            // Goal Line at 60 oz
            goalLine()
        }
        .chartYScale(domain: 0...maxMonthlyIntake)
        .chartXAxis {
            AxisMarks(values: .automatic) { _ in }
        }
        .frame(height: 200)
    }
    
    // MARK: - Find Closest Data Point (Fix Hover)
    private func findClosestData(to location: CGPoint, in proxy: ChartProxy) -> DailyHydrationData? {
        guard !monthlyData.isEmpty else {
            return nil
        }

        if let dayName = proxy.value(atX: location.x, as: String.self) {
            return monthlyData.first(where: { $0.dayName == dayName })
        }

        return nil
    }

    // MARK: - Tooltip Overlay (Fix: Now Properly Displays)
    private func hoverTooltip() -> some View {
        GeometryReader { _ in
            if let selectedDate, let selectedIntake, let selectedPosition {
                VStack {
                    Text("\(selectedDate): \(selectedIntake, specifier: "%.1f") oz")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.white)
                        .padding(6)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue))
                        .position(x: selectedPosition.x, y: max(selectedPosition.y - 40, 20))
                }
            }
        }
    }
    
    private func goalLine() -> some ChartContent {
        RuleMark(y: .value("Goal", 60))
            .foregroundStyle(.red)
            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
            .annotation(position: .top, alignment: .leading) {
                Text("Goal")
                    .font(.caption)
                    .foregroundColor(.red)
            }
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
