//
//  DashboardView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 2/25/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

@_spi(TestingSupport) import SpeziAccount
import SwiftUI

struct DashboardView: View {
	@Environment(Account.self) private var account: Account?
	@Binding private var presentingAccount: Bool
	
	var body: some View {
		NavigationView {
			DashboardTimeFrameView()
				.navigationTitle("My Dashboard")
				.toolbar {
					if account != nil {
						AccountButton(isPresented: $presentingAccount)
					}
				}
		}
		.toolbar {
			if account != nil {
				AccountButton(isPresented: $presentingAccount)
			}
		}
	}

	init(presentingAccount: Binding<Bool>) {
        self._presentingAccount = presentingAccount
    }
}

#Preview {
	@Previewable @State var standard = Stanford360Standard()
	@Previewable @State var presentingAccount = false
	
	@Previewable @State var patientManager = PatientManager(patient: Patient(
		weight: Measurement(value: 0, unit: .pounds),
		activityMinutes: 50,
		hydrationOunces: 40,
		proteinGrams: 10
	))
	
	@Previewable @State var activityManager = ActivityManager(activities: activitiesData)
	
	@Previewable @State var hydrationManager = HydrationManager()
	
	@Previewable @State var proteinManager = ProteinManager(meals: mealsData)
	
	DashboardView(presentingAccount: $presentingAccount)
		.environment(standard)
		.environment(patientManager)
		.environment(activityManager)
		.environment(hydrationManager)
		.environment(proteinManager)
}
