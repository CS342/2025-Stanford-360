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
	var patient: Patient
	
	init(patient: Patient = Patient(activityMinutes: 0, hydrationOunces: 0, proteinGrams: 0)) {
		self.patient = patient
	}
	
	func updateActivityMinutes(_ minutes: Int) {
		self.patient.activityMinutes = minutes
	}
	
	func updateHydrationOunces(_ ounces: Double) {
		self.patient.hydrationOunces = ounces
	}
	
	func updateProteinGrams(_ grams: Double) {
		self.patient.proteinGrams = grams
	}
}
