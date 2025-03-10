//
//  Toolbar.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/9/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

@_spi(TestingSupport) import SpeziAccount
import SwiftUI

struct Toolbar: ToolbarContent {
	@Environment(Account.self) private var account: Account?
	@Binding private var presentingAccount: Bool
	var title: String
	
	var body: some ToolbarContent {
		ToolbarItem(placement: .navigationBarLeading) {
			Text(title)
				.font(.system(size: 20, weight: .bold))
		}
		
		ToolbarItem(placement: .navigationBarTrailing) {
			if account != nil {
				AccountButton(isPresented: $presentingAccount)
			}
		}
	}
	
	init(presentingAccount: Binding<Bool>, title: String) {
		self._presentingAccount = presentingAccount
		self.title = title
	}
}

#Preview {
	@Previewable @State var presentingAccount = false
	
	var details = AccountDetails()
	details.userId = "lelandstanford@stanford.edu"
	details.name = PersonNameComponents(givenName: "Leland", familyName: "Stanford")
	
	return NavigationView {
		Text("Content")
			.toolbar {
				Toolbar(presentingAccount: $presentingAccount, title: "My Activity 👟")
			}
	}
	.previewWith(standard: Stanford360Standard()) {
		AccountConfiguration(service: InMemoryAccountService(), activeDetails: details)
	}
}
