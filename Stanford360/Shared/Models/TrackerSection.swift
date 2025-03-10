//
//  TrackerType.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/10/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

enum TrackerSection: String, CaseIterable, Identifiable {
	case add, history, discover
	
	var id: String { rawValue }
}
