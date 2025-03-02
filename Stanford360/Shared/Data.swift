//
//  Data.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/2/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation

let activitiesData = [
	Activity(
		date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
		steps: 4000,
		activeMinutes: 40,
		caloriesBurned: 0,
		activityType: "Walking"
	),
	Activity(
		date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
		steps: 2000,
		activeMinutes: 20,
		caloriesBurned: 0,
		activityType: "Walking"
	),
	Activity(
		date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
		steps: 1000,
		activeMinutes: 10,
		caloriesBurned: 0,
		activityType: "Walking"
	),
	Activity(
		date: Date.now,
		steps: 5500,
		activeMinutes: 55,
		caloriesBurned: 0,
		activityType: "Walking"
	)
]

let mealsData = [
	Meal(
		name: "Fish",
		proteinGrams: 30,
		timestamp: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date()
	),
	Meal(
		name: "Beef",
		proteinGrams: 70,
		timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
	),
	Meal(
		name: "Chicken",
		proteinGrams: 15,
		timestamp: Date.now
	)
]
