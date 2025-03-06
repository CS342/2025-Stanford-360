//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct HydrationTimeFrameView: View {
    @State var selectedTimeFrame: TimeFrame = .today
    
    var body: some View {
        VStack {
            TimeFramePicker(selectedTimeFrame: $selectedTimeFrame)
            TabView(selection: $selectedTimeFrame) {
                HydrationTodayView()
                    .tag(TimeFrame.today)
                HydrationWeeklyView()
                    .tag(TimeFrame.week)
                HydrationMonthlyView()
                    .tag(TimeFrame.month)
            }
            .tabViewStyle(PageTabViewStyle())
            .frame(height: 250)
        }
    }
}

#Preview {
    HydrationTimeFrameView()
}
