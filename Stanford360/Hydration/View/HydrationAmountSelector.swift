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

    let presetAmounts: [(icon: String, amount: Double)] = [
        (icon: "small_mug", amount: 8.0),
        (icon: "large_mug", amount: 10.0),
        (icon: "medium_mug", amount: 12.0),
        (icon: "small_water", amount: 16.0),
        (icon: "medium_water", amount: 20.0),
        (icon: "large_water", amount: 32.0)
    ]

    var body: some View {
        let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(presetAmounts, id: \.amount) { item in
                VStack(spacing: 6) {
                    Image(item.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(
                            width: [16, 20, 32].contains(item.amount) ? 40 : 30,
                            height: [16, 20, 32].contains(item.amount) ? 40 : 30
                        )
                        .clipped()
                        .accessibilityLabel("\(Int(item.amount)) oz water")

                    Text("\(Int(item.amount)) oz")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                .frame(width: 65, height: 65)
                .padding()
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 12).fill(Color.white)
                        if selectedAmount == item.amount {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue, lineWidth: 3)
                        }
                    }
                )
                .shadow(radius: 2)
                .onTapGesture {
                    selectedAmount = item.amount
                    errorMessage = nil
                }
            }
        }
        .padding(.horizontal)
    }
}
