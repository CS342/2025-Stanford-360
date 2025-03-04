//
//  AppNavigationState.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/4/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SwiftUI

@MainActor
@Observable
final class AppNavigationState: Module, EnvironmentAccessible {
	var showAccountSheet: Bool = false
}
