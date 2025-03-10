//
//  ProteinDiscoverView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/10/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProteinDiscoverView: View {
    var body: some View {
		ScrollView {
			VStack(spacing: 0) { // Reduced spacing to 0
				balancedPlateSection
				proteinGuideSection
				produceInSeasonSection
				restaurantRecommendationsSection
			}
		}
    }
	
	private var proteinGuideSection: some View {
		VStack(spacing: 0) {
			sectionHeader(title: "My Protein Pocket Guide")
				.padding(.bottom, 0) // No bottom padding
			
			Image("ProteinExamples1")
				.resizable()
				.scaledToFit()
				.frame(width: 350, height: 650)
				.padding(0) // Remove all padding
				.accessibilityLabel("Protein Recommendations")
			
			Image("ProteinExamples2")
				.resizable()
				.scaledToFit()
				.frame(width: 350, height: 650)
				.padding(0) // Remove all padding
				.accessibilityLabel("Protein Recommendations")
		}
	}
	
	private var produceInSeasonSection: some View {
		VStack(spacing: 0) {
			sectionHeader(title: "Shop for Produce in Season")
				.padding(.top, 8) // Add minimal top padding for section separation
				.padding(.bottom, 0) // No bottom padding
			
			Image("ProduceInSeason")
				.resizable()
				.scaledToFit()
				.frame(width: 350, height: 450)
				.padding(0) // Remove all padding
				.accessibilityLabel("Produce In Season Recommendations")
		}
	}
	
	private var restaurantRecommendationsSection: some View {
		VStack(spacing: 0) {
			sectionHeader(title: "Food choices at common restaurants")
				.padding(.top, 8) // Add minimal top padding for section separation
				.padding(.bottom, 0) // No bottom padding
			
			Text("On occasions when you eat out, the following are healthier suggestions from common chain restaurants")
				.font(.subheadline)
				.foregroundColor(.secondary)
				.multilineTextAlignment(.center)
				.padding()
				.padding(.vertical, 4) // Very minimal padding
			
			Image("FoodRestaurants")
				.resizable()
				.scaledToFit()
				.frame(width: 350, height: 650)
				.padding(0) // Remove all padding
				.accessibilityLabel("Food in common restaurants recommendations")
		}
	}
	
	private var balancedPlateSection: some View {
		VStack(spacing: 0) {
			sectionHeader(title: "Keep a Balanced Plate")
				.padding(.top, 8) // Add minimal top padding for section separation
				.padding(.bottom, 0) // No bottom padding
			
			Image("BalancedPlate")
				.resizable()
				.scaledToFit()
				.frame(width: 350, height: 650)
				.padding(0) // Remove all padding
				.accessibilityLabel("Balanced Plate Recommendations")
		}
	}
	
	private func sectionHeader(title: String) -> some View {
		Text(title)
			.font(.headline)
			.foregroundColor(.primary)
			.multilineTextAlignment(.center)
			.padding(.vertical, 8) // Reduced padding
	}
}

#Preview {
    ProteinDiscoverView()
}
