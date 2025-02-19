//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
//  Patient.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 2/6/25.
//

import Foundation

struct Patient: Identifiable {
	var id = UUID()
	var firstName: String
	var lastName: String
	var dateOfBirth: Date
	var height: Measurement<UnitLength>?
	var weight: Measurement<UnitMass>?
	var genderIdentity: String
	
	var fullName: String {
		"\(firstName) \(lastName)"
	}
	
	var age: Int {
		Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date.now).year ?? 0
	}
	
	var initials: String {
		if firstName.first == nil || lastName.first == nil {
			return "N/A"
		}
		
		return "\(firstName.first ?? " ")\(lastName.first ?? " ")"
	}
}
