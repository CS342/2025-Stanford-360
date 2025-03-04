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
    // MARK: - TimeFrame Enum
    enum HydrationTimeFrame {
        case today
        case week
        case month
    }

    // MARK: - State
    @State var intakeAmount: String = ""
    @State var errorMessage: String?
    @State var milestoneMessage: String?
    @State var totalIntake: Double = 0.0
    @State var streak: Int?
    @State var selectedAmount: Double?
    @State var isStreakUpdated: Bool = false
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
    @Environment(HydrationScheduler.self) var hydrationScheduler
    @Environment(PatientManager.self) var patientManager
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
                    hydrationPeriodPicker()
                    
                    switch selectedTimeFrame {
                    case .today:
                        todayView()
                    case .week:
                        weeklyView()
                    case .month:
                        monthlyView()
                    }
                }
            }
            .navigationTitle("My Hydration 💧")
            .toolbar {
                if account != nil {
                    AccountButton(isPresented: $presentingAccount)
                }
            }
            .onAppear {
                Task {
                    await loadHydrationLogs()
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
    
    func loadHydrationLogs() async {
            do {
                if let fetchedLog = try await standard.fetchHydrationLog() {
                    hydrationManager.hydration = [fetchedLog]
                    totalIntake = fetchedLog.amountOz
                    streak = fetchedLog.streak
                    isStreakUpdated = fetchedLog.isStreakUpdated
                    patientManager.updateHydrationOunces(fetchedLog.amountOz)
                } else {
                    hydrationManager.hydration = []
                    totalIntake = 0
                    isStreakUpdated = false

                    // Fetch yesterday's streak if no data exists for today
                    let yesterdayStreak = await standard.fetchYesterdayStreak()
                    streak = yesterdayStreak
                }
            } catch {
                print("❌ Error fetching hydration logs: \(error)")
                hydrationManager.hydration = []
                isStreakUpdated = false
            }

            // Fetch weekly and monthly hydration data
            weeklyData = await standard.fetchWeeklyHydrationData()
            monthlyData = await standard.fetchMonthlyHydrationData()
        }
}

// MARK: - Preview
#Preview {
    @Previewable @State var presentingAccount = false

    HydrationTrackerView(presentingAccount: $presentingAccount)
        .environment(Stanford360Standard())
}
