//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

@_spi(TestingSupport) import SpeziAccount
import SwiftUI

struct DailyHydrationData: Identifiable {
    let id = UUID()
    let dayName: String
    let intakeOz: Double
}

struct HydrationTrackerView: View {
    @Environment(Account.self) private var account: Account?
    @Binding private var presentingAccount: Bool

    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    HydrationTimeFrameView()
                    HydrationControlPanel()
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
