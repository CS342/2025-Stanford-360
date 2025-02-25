//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
//  FeedView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 2/6/25.
//

@_spi(TestingSupport) import SpeziAccount
import SwiftUI

struct FeedView: View {
	@Environment(Account.self) private var account: Account?
	@AppStorage(StorageKeys.homeTabSelection) private var selectedTab = HomeView.Tabs.home
	
	@Binding private var presentingAccount: Bool
	
	var body: some View {
		NavigationStack {
			ScrollView {
				VStack {
					DayTimelineView(selectedTab: $selectedTab)
				}
			}
			.navigationTitle("Today")
			.toolbar {
				if account != nil {
					AccountButton(isPresented: $presentingAccount)
				}
			}
		}
	}
	
	init(presentingAccount: Binding<Bool>) {
		self._presentingAccount = presentingAccount
	}
}

#Preview {
	@Previewable @State var presentingAccount = false
	
    FeedView(presentingAccount: $presentingAccount)
		.previewWith(standard: Stanford360Standard()) {
			AccountConfiguration(service: InMemoryAccountService())
		}
}
