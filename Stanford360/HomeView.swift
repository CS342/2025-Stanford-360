//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

@_spi(TestingSupport) import SpeziAccount
import class SpeziScheduler.Scheduler
import SwiftUI


struct HomeView: View {
	enum Tabs: String {
		case home
		case hydration
		case protein
		case activity
		case dashboard
	}
	
	@AppStorage(StorageKeys.homeTabSelection) private var selectedTab = Tabs.home
	@AppStorage(StorageKeys.tabViewCustomization) private var tabViewCustomization = TabViewCustomization()
	
	@State private var presentingAccount = false
	
	var body: some View {
		TabView(selection: $selectedTab) {
			Tab("Home", systemImage: "house.fill", value: .home) {
				FeedView(presentingAccount: $presentingAccount)
			}
			.customizationID("home.home")
			
			Tab("Activity", systemImage: "figure.walk", value: .activity) {
				ActivityView()
			}
			.customizationID("home.activity")
			
			Tab("Hydration", systemImage: "drop.fill", value: .hydration) {
				HydrationTrackerView()
			}
			.customizationID("home.hydration")
			
			Tab("Protein", systemImage: "fork.knife", value: .protein) {
                ProteinTrackerView()
			}
			.customizationID("home.protein")
			
			Tab("Dashboard", systemImage: "target", value: .dashboard) {
				DashboardView()
			}
			.customizationID("home.dashboard")
		}
		.tabViewStyle(.sidebarAdaptable)
		.tabViewCustomization($tabViewCustomization)
		.sheet(isPresented: $presentingAccount) {
			AccountSheet(dismissAfterSignIn: false) // presentation was user initiated, do not automatically dismiss
		}
		.accountRequired(!FeatureFlags.disableFirebase && !FeatureFlags.skipOnboarding) {
			AccountSheet()
		}
	}
}


#if DEBUG
#Preview {
	var details = AccountDetails()
	details.userId = "lelandstanford@stanford.edu"
	details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")
	
	return HomeView()
		.previewWith(standard: Stanford360Standard()) {
			Stanford360Scheduler()
			Scheduler()
			AccountConfiguration(service: InMemoryAccountService(), activeDetails: details)
		}
}
#endif
