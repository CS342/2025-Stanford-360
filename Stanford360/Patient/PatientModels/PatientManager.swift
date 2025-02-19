//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
//  PatientManager.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 2/10/25.
//

import Foundation
import Spezi

enum PatientManagerError: Error {
	case patientNotAvailable
}

final class PatientManager: Module, DefaultInitializable, EnvironmentAccessible {
	@Published var patient: Patient?
	
	init() {}
	
	func updatePatientHeight(_ height: Measurement<UnitLength>) throws {
		guard var patient else {
			throw PatientManagerError.patientNotAvailable
			// show error message that the patient isn't available so you can't update this right now
		}
		
		patient.height = height
	}
	
	func updatePatientHeight(_ height: Double) throws {
		try updatePatientHeight(Measurement(value: height, unit: .feet))
	}
	
	func updatePatientWeight(_ weight: Measurement<UnitMass>) throws {
		guard var patient else {
			throw PatientManagerError.patientNotAvailable
		}
		
		patient.weight = weight
	}
	
	func updatePatientWeight(_ height: Double) throws {
		try updatePatientWeight(Measurement(value: height, unit: .pounds))
	}
	
	//	func remindPatientToUpdateWeight() {
	//		let identifier = "remind-patient-to-update-weight"
	//		let title = "Time to update your weight!"
	//		let body = "Remember you must update this every week"
	//		let weekday = 2
	//		let hour = 18
	//		let minute = 45
	//		let isWeekly = true
	//
	//		let notificationCenter = UNUserNotificationCenter.current()
	//		let content = UNMutableNotificationContent()
	//		content.title = title
	//		content.body = body
	//		content.sound = .default
	//
	//		let calendar = Calendar.current
	//		var dateComponents = DateComponents(calendar: calendar, timeZone: TimeZone.current)
	//		dateComponents.weekday = weekday
	//		dateComponents.hour = hour
	//		dateComponents.minute = minute
	//
	//		let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: isWeekly)
	//		let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
	//
	//		notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
	//		notificationCenter.add(request)
	//	}
}
