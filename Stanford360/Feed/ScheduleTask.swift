//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
//  ScheduleTask.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 2/24/25.
//

import Foundation
import SwiftUICore

struct ScheduleTask: Identifiable {
	let id = UUID()
	let title: String
	let time: String
	let category: TaskCategory
	var isCompleted: Bool
	var date: Date
	var navigationType: NavigationType?
}

extension ScheduleTask {
	enum TaskCategory: String, CaseIterable {
		case meal
		case medication
		case exercise
		case water
		case other
		
		var color: Color {
			switch self {
			case .meal: return Color.blue
			case .medication: return Color.purple
			case .exercise: return Color.orange
			case .water: return Color.teal
			case .other: return Color.gray
			}
		}
		
		var icon: String {
			switch self {
			case .meal: return "fork.knife"
			case .medication: return "pill"
			case .exercise: return "figure.walk"
			case .water: return "drop"
			case .other: return "checklist"
			}
		}
	}
	
	enum NavigationType {
		case protein
		case activity
		case hydration
		
		var tabValue: HomeView.Tabs {
			switch self {
			case .protein: return .protein
			case .activity: return .activity
			case .hydration: return .hydration
			}
		}
	}
}
