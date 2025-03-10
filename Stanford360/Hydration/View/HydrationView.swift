//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

@_spi(TestingSupport) import SpeziAccount
import SwiftUI

struct HydrationView: View {
	@Binding private var presentingAccount: Bool
	
	// MARK: - Body
	var body: some View {
		NavigationView {
			VStack(spacing: 20) {
				HydrationTabView()
			}
			.toolbar {
				Toolbar(presentingAccount: $presentingAccount, title: "My Hydration 💧")
			}
			.contentShape(Rectangle())
			.onTapGesture {
				UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
			}
		}
	}
	
	init(presentingAccount: Binding<Bool>) {
		self._presentingAccount = presentingAccount
	}
}

// MARK: - Preview
#Preview {
	@Previewable @State var presentingAccount = false
	
	HydrationView(presentingAccount: $presentingAccount)
		.environment(Stanford360Standard())
}
