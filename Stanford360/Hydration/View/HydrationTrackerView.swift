//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct HydrationTrackerView: View {
    // MARK: - TimeFrame Enum
    enum HydrationTimeFrame {
        case today
        case week
        case month
    }
	
	@Environment(PatientManager.self) var patientManager

    // MARK: - State
    @State var intakeAmount: String = ""
    @State var errorMessage: String?
    @State var milestoneMessage: String?
    @State var totalIntake: Double = 0.0
    @State var streak: Int?
    @State var selectedAmount: Double?
    @State var streakJustUpdated = false
    @State var isSpecialMilestone: Bool = false
    @State var selectedTimeFrame: HydrationTimeFrame = .today
    @State var weeklyData: [DailyHydrationData] = []
    @State var monthlyData: [DailyHydrationData] = []
    @State var selectedDate: String?
    @State var selectedIntake: Double?
    @State var selectedPosition: CGPoint?
    var maxMonthlyIntake: Double {
        max(200, monthlyData.map { $0.intakeOz }.max() ?? 0)
    }
    var maxWeeklyIntake: Double {
        max(100, weeklyData.map { $0.intakeOz }.max() ?? 0)
    }

    @Environment(Stanford360Standard.self) var standard

    // MARK: - Preset Amounts
    let presetAmounts: [(icon: String, amount: Double)] = [
        (icon: "small_mug", amount: 8.0),
        (icon: "large_mug", amount: 10.0),
        (icon: "medium_mug", amount: 12.0),
        (icon: "small_water", amount: 16.0),
        (icon: "medium_water", amount: 20.0),
        (icon: "large_water", amount: 32.0)
    ]

    // MARK: - Body
    var body: some View {
        ZStack {
            /*
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.white]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
             */
            ScrollView {
                VStack(spacing: 20) {
                    headerView()
                    hydrationPeriodPicker()
                    
                    // Tab content
                    switch selectedTimeFrame {
                    case .today:
                        todayView()
                    case .week:
                        weeklyView()
                    case .month:
                        monthlyView()
                    }
                }
                .padding(.top, 30)
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .onAppear {
                Task {
                    await fetchHydrationData()
                    weeklyData = await standard.fetchWeeklyHydrationData()
                    monthlyData = await standard.fetchMonthlyHydrationData()
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }
    
    func hydrationPeriodPicker() -> some View {
        Picker("Hydration Period", selection: $selectedTimeFrame) {
            Text("Today").tag(HydrationTimeFrame.today)
            Text("This Week").tag(HydrationTimeFrame.week)
            Text("This Month").tag(HydrationTimeFrame.month)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
    }
}

// MARK: - Preview
#Preview {
    HydrationTrackerView()
        .environment(Stanford360Standard())
}
