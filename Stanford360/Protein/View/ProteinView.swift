//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

@_spi(TestingSupport) import SpeziAccount
import SwiftUI

struct ProteinView: View {
	@State private var showingAddProtein = false
	
	@Binding private var presentingAccount: Bool
	
	var body: some View {
		NavigationStack {
			ZStack {
				VStack(spacing: 20) {
					ProteinTabView()
				}
				
				buttons
			}
			.toolbar {
				Toolbar(presentingAccount: $presentingAccount, title: "My Protein 🍴")
			}
			.sheet(isPresented: $showingAddProtein) {
				AddMealView()
			}
		}
	}
	
	private var buttons: some View {
		ZStack {
			HStack {
				Spacer()
				IconButton(
					showingAddItem: $showingAddProtein,
					imageName: "plus.circle.fill",
					imageAccessibilityLabel: "Add Protein Button",
					color: .blue
				)
				.padding(.trailing, 10)
			}
		}
	}
	
	init(presentingAccount: Binding<Bool>) {
		self._presentingAccount = presentingAccount
	}
}

#if DEBUG
#Preview {
	@Previewable @State var presentingAccount = false
	ProteinView(presentingAccount: $presentingAccount)
}
#endif
