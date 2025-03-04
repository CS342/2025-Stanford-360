//
//  Patient.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 2/25/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation

struct Patient {
	// periphery:ignore - weight will be stored to firestore in a follow up pr
	var weight: Measurement<UnitMass>
	var activityMinutes: Int
	var hydrationOunces: Double
	var proteinGrams: Double
}
