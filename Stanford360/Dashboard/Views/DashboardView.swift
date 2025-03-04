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
	@Environment(Stanford360Standard.self) private var standard
	@Environment(PatientManager.self) private var patientManager
	@Environment(ActivityManager.self) private var activityManager
	@Environment(HydrationManager.self) private var hydrationManager
	@Environment(ProteinManager.self) private var proteinManager
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
		.task {
			await loadPatientData()
		}
	}

	init(presentingAccount: Binding<Bool>) {
        self._presentingAccount = presentingAccount
    }
	
	/// Loads the patient's activities, hydration, and meals into their respective managers and updates the patient's data accordingly
	func loadPatientData() async {
		let patientData = try? await standard.fetchPatientData()
		
		activityManager.activities = patientData?.activities ?? []
		let activityMinutes = activityManager.getTodayTotalMinutes()
		patientManager.updateActivityMinutes(activityMinutes)
		
		hydrationManager.hydration = patientData?.hydration ?? []
		let hydrationOunces = hydrationManager.getTodayHydrationOunces()
		patientManager.updateHydrationOunces(hydrationOunces)
		
		proteinManager.meals = patientData?.meals ?? []
		let proteinGrams = proteinManager.getTodayTotalGrams()
		patientManager.updateProteinGrams(proteinGrams)
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
