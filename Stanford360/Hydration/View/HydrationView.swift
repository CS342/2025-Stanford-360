//
//  HydrationView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/4/25.
//

@_spi(TestingSupport) import SpeziAccount
import SwiftUI

struct HydrationView: View {
//	@Environment(PatientManager.self) var patientManager
	@Environment(Stanford360Standard.self) var standard
	@Environment(HydrationManager.self) var hydrationManager
//	@Environment(HydrationScheduler.self) var hydrationScheduler
	@Environment(Account.self) private var account: Account?
	
	@Binding private var presentingAccount: Bool
	
	@State var selectedTimeFrame: TimeFrame = .today
	
	var body: some View {
		NavigationView {
			VStack(spacing: 20) {
				HydrationTimeFrameView()
			}
			.navigationTitle("My Hydration 💧")
			.toolbar {
				if account != nil {
					AccountButton(isPresented: $presentingAccount)
				}
			}
			.task {
				await loadHydration()
			}
			.onTapGesture {
				UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
			}
		}
	}
	
	init(presentingAccount: Binding<Bool>) {
		self._presentingAccount = presentingAccount
	}
	
	func loadHydration() async {
		hydrationManager.hydration = await standard.fetchHydration()
	}
}

#Preview {
	@Previewable @State var presentingAccount = false
	
	HydrationView(presentingAccount: $presentingAccount)
		.environment(Stanford360Standard())
		.environment(HydrationManager())
}
