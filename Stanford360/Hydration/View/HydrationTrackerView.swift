//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

@_spi(TestingSupport) import SpeziAccount
import SwiftUI

struct HydrationTrackerView: View {
    // MARK: - State
    @State var intakeAmount: String = ""
    @State var errorMessage: String?
    @State var milestoneMessage: String?
    @State var selectedAmount: Double?
    @State var streakJustUpdated = false
    @State var isSpecialMilestone: Bool = false
    @State var selectedTimeFrame: TimeFrame = .today
    @State var selectedDate: String?
    @State var selectedIntake: Double?
    @State var selectedPosition: CGPoint?
    var maxMonthlyIntake: Double {
        max(200, monthlyData.map { $0.intakeOz }.max() ?? 0)
    }
    var maxWeeklyIntake: Double {
        max(100, weeklyData.map { $0.intakeOz }.max() ?? 0)
    }
    
    var weeklyData: [DailyHydrationData] {
        let calendar = Calendar.current
        let weekdaySymbols = calendar.shortWeekdaySymbols
        var weeklyIntake: [String: Double] = weekdaySymbols.reduce(into: [:]) { $0[$1] = 0 }

        for log in hydrationManager.hydration where calendar.isDate(log.timestamp, equalTo: Date(), toGranularity: .weekOfYear) {
            let weekday = calendar.component(.weekday, from: log.timestamp)
            let dayName = weekdaySymbols[weekday - 1]
            weeklyIntake[dayName, default: 0] += log.hydrationOunces
        }

        return weekdaySymbols.map { dayName in
            DailyHydrationData(dayName: dayName, intakeOz: weeklyIntake[dayName] ?? 0)
        }
    }

    var monthlyData: [DailyHydrationData] {
        var monthlyIntake: [String: Double] = [:]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"

        for log in hydrationManager.hydration {
            let day = dateFormatter.string(from: log.timestamp)
            monthlyIntake[day, default: 0] += log.hydrationOunces
        }

        return monthlyIntake.keys.sorted().map { day in
            DailyHydrationData(dayName: day, intakeOz: monthlyIntake[day] ?? 0)
        }
    }

    @Environment(Stanford360Standard.self) var standard
    @Environment(HydrationScheduler.self) var hydrationScheduler
    @Environment(HydrationManager.self) var hydrationManager
    @Environment(Account.self) private var account: Account?
    @Binding private var presentingAccount: Bool

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
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    TimeFramePicker(selectedTimeFrame: $selectedTimeFrame)
                    
                    switch selectedTimeFrame {
                    case .today:
                        todayView()
                    case .week:
                        weeklyView()
                    case .month:
                        monthlyView()
                    }
                }
                .navigationTitle("My Hydration 💧")
            }
            .toolbar {
                if account != nil {
                    AccountButton(isPresented: $presentingAccount)
                }
            }
			.contentShape(Rectangle())
			.onTapGesture {
				UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
			}
        }
    }
    
    init(presentingAccount: Binding<Bool>) {
            self._presentingAccount = presentingAccount
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var presentingAccount = false

    HydrationTrackerView(presentingAccount: $presentingAccount)
        .environment(Stanford360Standard())
}
