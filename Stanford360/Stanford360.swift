//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseCore
import Spezi
import SpeziFirebaseAccount
import SpeziViews
import SwiftUI

@main
struct Stanford360: App {
    @UIApplicationDelegateAdaptor(Stanford360Delegate.self) var appDelegate
    @AppStorage(StorageKeys.onboardingFlowComplete) var completedOnboardingFlow = false
    
    @State private var activityManager = ActivityManager()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if completedOnboardingFlow {
                    HomeView().environment(activityManager)
                } else {
                    EmptyView()
                }
            }
                .sheet(isPresented: !$completedOnboardingFlow) {
                    OnboardingFlow()
                }
                .testingSetup()
                .spezi(appDelegate)
        }
    }
}
