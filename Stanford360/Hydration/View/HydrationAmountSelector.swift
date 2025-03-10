//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct HydrationAmountSelector: View {
    @Binding var selectedAmount: Double?
    @Binding var errorMessage: String?

    private let hydrationOptions: [(icon: String, amount: Double)] = [
        (icon: "small_mug", amount: 8.0),
        (icon: "large_mug", amount: 10.0),
        (icon: "medium_mug", amount: 12.0),
        (icon: "small_water", amount: 16.0),
        (icon: "medium_water", amount: 20.0),
        (icon: "large_water", amount: 32.0)
    ]

    var body: some View {
        SelectorView(
            selectedAmount: $selectedAmount,
            errorMessage: $errorMessage,
            options: hydrationOptions,
            unit: "oz"
        )
    }
}
