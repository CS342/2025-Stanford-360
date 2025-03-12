//
//  MealDetailView.swift
//  Stanford360
//
//  Created by Jiayu Chang on 3/11/25.
//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Firebase
import SwiftUI

struct MealDetailView: View {
    let meal: Meal
    @State private var mealImage: UIImage?
    @State private var isLoading = false
    
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
        // .background(Color(UIColor.systemGroupedBackground))
    }
    
    private var headerSection: some View {
        // Your existing code
        VStack(spacing: 8) {
            Text(meal.name)
                .font(.system(.title, design: .rounded))
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
        }
    }
    
    // Extracted placeholder image content as a separate view for cleaner code
    private var placeholderImageContent: some View {
        VStack(spacing: 12) {
            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
                .accessibilityLabel("fork")
            
            Text("No Image Available")
                .font(.caption)
                .foregroundColor(.secondary)
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

    // Frame background
    private var frameBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.white)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
    }

    // Inner border
    private var innerBorder: some View {
        RoundedRectangle(cornerRadius: 12)
            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            .padding(8)
    }

    // Image content view
    @ViewBuilder private var imageContent: some View {
        if isLoading {
            ProgressView()
        } else if let image = mealImage {
            loadedImageView(image)
        } else if let imageURL = meal.imageURL, let url = URL(string: imageURL) {
            asyncImageView(url)
        } else {
            placeholderImageContent
        }
    }

    // View for loaded UIImage
    private func loadedImageView(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding(8)
            .cornerRadius(8)
            .accessibilityLabel("image")
    }
    
    @ViewBuilder
    private func mealImageView() -> some View {
        ZStack {
            // Photo frame background
            frameBackground
            // Inner border
            innerBorder
            // Image content
            imageContent
        }
        .frame(height: 350)
        .padding(.horizontal, 20)
    }

    // View for async loaded image
    private func asyncImageView(_ url: URL) -> some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(8)
                    .cornerRadius(8)
            case .failure, _:
                placeholderImageContent
            }
        }
        .padding(8)
    }
}
