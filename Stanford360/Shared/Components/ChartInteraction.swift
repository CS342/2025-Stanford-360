//
// ChartInteractionHelper.swift
// Stanford360
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
/*
import Charts
import SwiftUI

enum ChartInteractionHelper {
    // MARK: - Chart Hover Gesture
    @MainActor
    static func chartHoverGesture(
        proxy: ChartProxy,
        data: [DailyHydrationData],
        selectedDate: Binding<String?>,
        selectedIntake: Binding<Double?>,
        selectedPosition: Binding<CGPoint?>
    ) -> some View {
        Color.clear
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let location = value.location
                        Task { @MainActor in
                            if let closestData = findClosestData(to: location, in: proxy, data: data) {
                                selectedDate.wrappedValue = closestData.dayName
                                selectedIntake.wrappedValue = closestData.intakeOz
                                selectedPosition.wrappedValue = location
                            }
                        }
                    }
                    .onEnded { _ in
                        Task { @MainActor in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                selectedDate.wrappedValue = nil
                                selectedIntake.wrappedValue = nil
                                selectedPosition.wrappedValue = nil
                            }
                        }
                    }
            )
    }

    // MARK: - Find Closest Data Point
    static func findClosestData(
        to location: CGPoint,
        in proxy: ChartProxy,
        data: [DailyHydrationData]
    ) -> DailyHydrationData? {
        guard !data.isEmpty else {
            return nil
        }
        
        if let dayName = proxy.value(atX: location.x, as: String.self) {
            return data.first(where: { $0.dayName == dayName })
        }
        return nil
    }

    // MARK: - Tooltip Overlay
    static func hoverTooltip(
        selectedDate: String?,
        selectedIntake: Double?,
        selectedPosition: CGPoint?
    ) -> some View {
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
}
*/
