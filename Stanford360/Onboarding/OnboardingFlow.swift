//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

@_spi(TestingSupport) import SpeziAccount
import SpeziFirebaseAccount
import SpeziHealthKit
import SpeziNotifications
import SpeziOnboarding
import class SpeziScheduler.Scheduler
import SwiftUI

/// Displays a multi-step onboarding flow for the Stanford 360.
struct OnboardingFlow: View {
    @Environment(HealthKit.self) private var healthKitDataSource

    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.notificationSettings) private var notificationSettings

    @AppStorage(StorageKeys.onboardingFlowComplete) private var completedOnboardingFlow = false

    @State private var localNotificationAuthorization = false
    
    
    @MainActor private var healthKitAuthorization: Bool {
        // As HealthKit not available in preview simulator
        if ProcessInfo.processInfo.isPreviewSimulator {
            return false
        }
        
        return healthKitDataSource.authorized
    }
    
    
    var body: some View {
        OnboardingStack(onboardingFlowComplete: $completedOnboardingFlow) {
            // Welcome()
            // InterestingModules()
            KidsOnboarding() // New onboarding view for kids
            
            if !FeatureFlags.disableFirebase {
                AccountOnboarding()
            }
            
            #if !(targetEnvironment(simulator) && (arch(i386) || arch(x86_64)))
                // Consent()
            #endif
            
            if HKHealthStore.isHealthDataAvailable() && !healthKitAuthorization {
                HealthKitPermissions()
            }
            
            if !localNotificationAuthorization {
                NotificationPermissions()
            }
        }
            .interactiveDismissDisabled(!completedOnboardingFlow)
            .onChange(of: scenePhase, initial: true) {
                guard case .active = scenePhase else {
                    return
                }

                Task {
                    localNotificationAuthorization = await notificationSettings().authorizationStatus == .authorized
                }
            }
    }
}


#if DEBUG
#Preview {
    OnboardingFlow()
        .previewWith(standard: Stanford360Standard()) {
            OnboardingDataSource()
            HealthKit()
            AccountConfiguration(service: InMemoryAccountService())

            Stanford360Scheduler()
            Scheduler()
        }
}
#endif
