//
//  DashboardWeeklyView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/2/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct DashboardWeeklyView: View {
    var body: some View {
		DashboardChartView(timeFrame: .week)
    }
}

#Preview {
    DashboardWeeklyView()
}
