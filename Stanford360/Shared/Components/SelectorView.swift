//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct SelectorView: View {
    @Binding var selectedAmount: Double?
    @Binding var errorMessage: String?

    let options: [(icon: String, amount: Double)]
    let unit: String

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(options, id: \.amount) { item in
                selectionItem(item)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Selection Item View
    private func selectionItem(_ item: (icon: String, amount: Double)) -> some View {
        VStack(spacing: 6) {
            selectionIcon(item.icon, amount: item.amount)
            selectionLabel(amount: item.amount)
        }
        .frame(width: 65, height: 65)
        .padding()
        .background(selectionBackground(item))
        .shadow(radius: 2)
        .onTapGesture {
            selectedAmount = item.amount
            errorMessage = nil
        }
    }

    // MARK: - Selection Icon
    private func selectionIcon(_ icon: String, amount: Double) -> some View {
        Image(icon)
            .resizable()
            .renderingMode(.template)
            .aspectRatio(contentMode: .fit)
            .frame(width: [16, 20, 32].contains(amount) ? 40 : 30, height: [16, 20, 32].contains(amount) ? 40 : 30)
            .clipped()
            .accessibilityLabel("\(Int(amount)) \(unit)")
    }

    // MARK: - Selection Label
    private func selectionLabel(amount: Double) -> some View {
        Text("\(Int(amount)) \(unit)")
            .font(.headline)
            .foregroundColor(.primary)
    }

    // MARK: - Background and Selection State
    private func selectionBackground(_ item: (icon: String, amount: Double)) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator), lineWidth: 1)
            if selectedAmount == item.amount {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, lineWidth: 3)
            }
        }
    }
}
