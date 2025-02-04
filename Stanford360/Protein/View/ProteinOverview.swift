//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProteinOverview: View {
    let totalProtein: Double

    var body: some View {
        VStack {
            Text("Total Protein Intake")
                .font(.headline)
            Text("\(totalProtein, specifier: "%.2f") g")
                .font(.largeTitle)
                .bold()
        }
        .padding()
    }
}
