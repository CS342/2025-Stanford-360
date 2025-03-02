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
		let patient = patientManager.patient
		
		VStack(alignment: .leading, spacing: 0) {
			Text("Today's Progress")
				.font(.system(size: 28, weight: .bold))
				.foregroundColor(.textPrimary)
				.padding(.horizontal, 20)
				.padding(.top, 40)
			
			ProgressRings()
			
			VStack(spacing: 15) {
				ProgressCard(
					title: "Activity",
					progress: CGFloat(patient.activityMinutes),
					color: .activityColor
				)
				
				ProgressCard(
					title: "Hydration",
					progress: CGFloat(patient.hydrationOunces),
					color: .hydrationColor
				)
				
				ProgressCard(
					title: "Protein",
					progress: CGFloat(patient.proteinGrams),
					color: .proteinColor
				)
			}
			.padding(.horizontal, 20)
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
		activityMinutes: 50,
		hydrationOunces: 40,
		proteinGrams: 10
	))
	
	@Previewable @State var activityManager = ActivityManager()
	
	@Previewable @State var hydrationManager = HydrationManager()
	
	@Previewable @State var proteinManager = ProteinManager()
	
	DashboardView(presentingAccount: $presentingAccount)
		.environment(standard)
		.environment(patientManager)
		.environment(activityManager)
		.environment(hydrationManager)
		.environment(proteinManager)
}
