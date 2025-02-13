//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct MealDetailView: View {
    let meal: Meal

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                mealImageView()
                mealInfoView()
            }
            .padding()
        }
        .navigationTitle("Meal Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func mealImageView() -> some View {
        if let imageURL = meal.imageURL, let url = URL(string: imageURL) {
            AsyncImage(url: url) { image in
                image.resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(12)
                    .shadow(radius: 5)
            } placeholder: {
                ProgressView()
            }
        } else {
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .frame(height: 200)
                .foregroundColor(.gray)
                .opacity(0.5)
                .cornerRadius(12)
        }
    }

    @ViewBuilder
    private func mealInfoView() -> some View {
        Text(meal.name)
            .font(.largeTitle)
            .bold()

        Text(String(format: "%.2f g of Protein", meal.proteinGrams))
            .font(.title2)
            .foregroundColor(.secondary)

//        if let description = meal.description {
//            Text(description)
//                .font(.body)
//                .padding(.horizontal)
//        }

        Text("Added on: \(meal.timestamp, style: .date)")
            .font(.footnote)
            .foregroundColor(.gray)
    }
}

