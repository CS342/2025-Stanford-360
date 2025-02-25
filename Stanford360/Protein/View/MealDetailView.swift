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
            VStack(spacing: 24) {
                // Hero Image Section
                mealImageView()
                    .frame(maxWidth: .infinity)
                
                // Content Section
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // Protein Info Card
                    proteinInfoCard
                    
                    // Meal Timestamp Card
                    timeInfoCard
                }
                .padding(.horizontal)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(meal.name)
                .font(.system(.title, design: .rounded))
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
        }
    }
    // add parameters
    private var proteinInfoCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                    .accessibilityLabel("flame")
                Text("Protein Content")
                    .font(.headline)
                Spacer()
            }
            
            HStack {
                Text(String(format: "%.1f", meal.proteinGrams))
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                Text("g")
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.leading, -4)
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var timeInfoCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.blue)
                    .accessibilityLabel("clock")
                Text("Intake time")// take in meals every 3 or 4 hours
                    .font(.headline)
                Spacer()
            }
            
            HStack {
                Text(meal.timestamp, style: .date)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.secondary)
                Spacer()
                
                Text(meal.timestamp, style: .time)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    
    private var placeholderImage: some View {
        ZStack {
            Rectangle()
                .fill(Color(UIColor.secondarySystemBackground))
            
            VStack(spacing: 12) {
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
                
                Text("No Image Available")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(height: 250)
    }
    
    @ViewBuilder
    private func mealImageView() -> some View {
        if let imageURL = meal.imageURL, let url = URL(string: imageURL) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(height: 250)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 250)
                        .clipped()
                case .failure:
                    placeholderImage
                @unknown default:
                    placeholderImage
                }
            }
        } else {
            placeholderImage
        }
    }
}

#if DEBUG
#Preview {
    NavigationView {
        MealDetailView(
            meal: Meal(
                name: "Grilled Chicken Salad",
                proteinGrams: 32.5,
                imageURL: nil, // how to present a picture on UI
                timestamp: Date()
            )
        )
    }
}
#endif
