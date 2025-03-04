//
//  ProteinTodayView.swift
//  Stanford360
//
//  Created by Jiayu Chang on 3/4/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProteinDailyView: View {
    @Environment(ProteinManager.self) private var proteinManager
    
    var body: some View {
        DailyRecordView(currentValue: proteinManager.getTodayTotalGrams(), maxValue: 60)
            .frame(height: 200)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 50) // Add spacing to prevent overlap
            .padding(.bottom, 20) // Ensure separation
    }
}
