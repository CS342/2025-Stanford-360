//
//  ActivityView.swift
//  Stanford360
//
//  Created by Elsa Bismuth on 30/01/2025.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT

import Charts
import FirebaseAuth
@_spi(TestingSupport) import SpeziAccount
import SwiftUI

struct ActivityView: View {
	@Environment(HealthKitManager.self) private var healthKitManager
	
	// State properties grouped together
	@State private var showingAddActivity = false
	@State private var showHealthKitAlert = false
	@Binding private var presentingAccount: Bool
	
	var body: some View {
		NavigationView {
			ZStack {
				VStack(spacing: 20) {
					if !healthKitManager.isHealthKitAuthorized {
						healthKitWarningBanner
					}
					
					ActivityTabView()
				}
				
				buttons
			}
			.toolbar {
				Toolbar(presentingAccount: $presentingAccount, title: "My Activity 👟")
			}
			.sheet(isPresented: $showingAddActivity) {
				AddActivitySheet()
			}
			.alert("HealthKit Access Required", isPresented: $showHealthKitAlert) {
				Button("Open Settings", role: .none) {
					if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
						UIApplication.shared.open(settingsURL)
					}
				}
				Button("Continue Without HealthKit", role: .cancel) { }
			} message: {
				Text("Enable HealthKit in Settings to auto-track steps, or log activities manually.")
			}
		}
	}
	
	private var buttons: some View {
		ZStack {
			HStack {
				Spacer()
				IconButton(
					showingAddItem: $showingAddActivity,
					imageName: "plus.circle.fill",
					imageAccessibilityLabel: "Add Activity Button",
					color: .blue
				)
				.padding(.trailing, 10)
			}
		}
	}
	
	// Extracted health kit warning banner
	private var healthKitWarningBanner: some View {
		VStack {
			Text("HealthKit Access Not Available")
				.font(.headline)
				.foregroundColor(.orange)
			Text("Activities must be logged manually")
				.font(.subheadline)
				.foregroundColor(.secondary)
		}
		.padding()
		.frame(maxWidth: .infinity)
		.background(Color.orange.opacity(0.1))
		.cornerRadius(10)
		.onTapGesture {
			showHealthKitAlert = true
		}
	}
	
	init(presentingAccount: Binding<Bool>) {
		self._presentingAccount = presentingAccount
	}
}

#if DEBUG
#Preview {
	@Previewable @State var presentingAccount = false
	var details = AccountDetails()
	details.userId = "lelandstanford@stanford.edu"
	details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")
	
	return ActivityView(presentingAccount: $presentingAccount)
		.previewWith(standard: Stanford360Standard()) {
			ActivityManager()
			HealthKitManager()
			AccountConfiguration(service: InMemoryAccountService(), activeDetails: details)
		}
}
#endif
