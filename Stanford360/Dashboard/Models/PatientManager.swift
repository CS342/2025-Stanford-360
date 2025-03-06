//
//  PatientManager.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 2/25/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import Spezi

@Observable
class PatientManager: Module, EnvironmentAccessible {
	@ObservationIgnored @StandardActor var standard: Stanford360Standard
	@ObservationIgnored @Dependency(ActivityManager.self) var activityManager
	@ObservationIgnored @Dependency(HydrationManager.self) var hydrationManager
	@ObservationIgnored @Dependency(ProteinManager.self) var proteinManager
	@ObservationIgnored @Dependency(HealthKitManager.self) var healthKitManager
	
	var patient: Patient
	
	init(
		patient: Patient = Patient(
			weight: Measurement(value: 0, unit: .pounds)
		)
	) {
		self.patient = patient
	}
	
	func configure() {
		Task {
			await loadPatientData()
		}
	}
	
	/// Loads the patient's activities, hydration, and meals into their respective managers and updates the patient's data accordingly
	func loadPatientData() async {
		let patientData = try? await standard.fetchPatientData()
		
		activityManager.activities = patientData?.activities ?? []
		await fetchHealthKitData()
		let activityMinutes = activityManager.getTodayTotalMinutes()
		
		hydrationManager.hydration = patientData?.hydration ?? []
		let hydrationOunces = hydrationManager.getTodayTotalOunces()
		
		proteinManager.meals = patientData?.meals ?? []
		let proteinGrams = proteinManager.getTodayTotalGrams()
	}
	
	func fetchHealthKitData() async {
		do {
			try await healthKitManager.requestAuthorization()
			await syncHealthKitData()
		} catch {
			print("Failed to setup HealthKit: \(error.localizedDescription)")
		}
	}
	
	func syncHealthKitData() async {
		do {
			// First check if HealthKit is authorized
			if await !healthKitManager.isHealthKitAuthorized {
				try await healthKitManager.requestAuthorization()
			}
			
			// Use fetchAndConvertHealthKitData to properly convert steps to minutes
			let healthKitActivity = try await healthKitManager.fetchAndConvertHealthKitData(for: Date())
			
			print("HealthKit data fetched: \(healthKitActivity.activeMinutes) minutes, \(healthKitActivity.steps) steps")
			
			// Remove any existing HealthKit activities for today - use consistent activity type
			let today = Calendar.current.startOfDay(for: Date())
			activityManager.activities.removeAll { activity in
				activity.activityType == "HealthKit Import" &&
				Calendar.current.startOfDay(for: activity.date) == today
			}
			
			// Only add if there are actual activities recorded
			if healthKitActivity.activeMinutes > 0 || healthKitActivity.steps > 0 {
				print("Adding HealthKit activity with \(healthKitActivity.activeMinutes) minutes")
				// Make sure we're not adding this activity to HealthKit again
				var activityCopy = healthKitActivity
				activityCopy.activityType = "HealthKit Import"
				activityManager.activities.append(activityCopy)
				activityManager.saveToStorage()
			} else {
				print("No significant HealthKit activity found for today")
			}
		} catch {
			print("Failed to sync HealthKit data: \(error.localizedDescription)")
		}
	}
	
	func updateWeight(_ pounds: Double) {
		self.patient.weight = Measurement(value: pounds, unit: .pounds)
	}
}
