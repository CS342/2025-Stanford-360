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
		case dashboard
		case hydration
		case protein
		case activity
	}
	
	@AppStorage(StorageKeys.homeTabSelection) private var selectedTab = Tabs.dashboard
	@AppStorage(StorageKeys.tabViewCustomization) private var tabViewCustomization = TabViewCustomization()
	
	@Environment(AppNavigationState.self) private var navigationState
	
	@State private var presentingAccount = false
	
	var body: some View {
		TabView(selection: $selectedTab) {
			Tab("Dashboard", systemImage: "target", value: .dashboard) {
				DashboardView(presentingAccount: $presentingAccount)
			}
			.customizationID("home.dashboard")
			
			Tab("Activity", systemImage: "figure.walk", value: .activity) {
				ActivityView(presentingAccount: $presentingAccount)
			}
			.customizationID("home.activity")
			
			Tab("Hydration", systemImage: "drop.fill", value: .hydration) {
				HydrationTrackerView(presentingAccount: $presentingAccount)
			}
			.customizationID("home.hydration")
			
			Tab("Protein", systemImage: "fork.knife", value: .protein) {
				ProteinView(presentingAccount: $presentingAccount)
			}
			.customizationID("home.protein")
		}
		.tabViewStyle(.sidebarAdaptable)
		.tabViewCustomization($tabViewCustomization)
		.sheet(isPresented: $presentingAccount) {
			AccountSheet(dismissAfterSignIn: false) // presentation was user initiated, do not automatically dismiss
		}
		.sheet(isPresented: Binding(
			get: { navigationState.showAccountSheet },
			set: { newValue in
				if !newValue {
					navigationState.showAccountSheet = false
				}
			}
		)) {
			AccountSheet()
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
