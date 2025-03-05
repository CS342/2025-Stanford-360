//
//  KidsOnboarding.swift
//  Stanford360
//
//  Created by Elsa Bismuth on 04/03/2025.
//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SpeziOnboarding
import SwiftUI

struct KidsOnboarding: View {
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath

    var body: some View {
        OnboardingView(
            title: "Welcome to Your Health Adventure! 🎉",
            subtitle: "Let's explore how to stay active and healthy!",
            areas: [
                OnboardingInformationView.Content(
                    icon: {
                        Image(systemName: "target")
                            .accessibilityHidden(true)
                    },
                    title: "Reach Your Goals 🎯",
                    description: "Track your progress with the 60/60/60 rule: 60 minutes of activity, 60 oz of water, and 60 grams of protein daily!"
                ),
                OnboardingInformationView.Content(
                    icon: {
                        Image(systemName: "lightbulb.fill")
                            .accessibilityHidden(true)
                    },
                    title: "Get Fun Suggestions 🎈",
                    description: "Need ideas for activities or meals? Just click the green '?' button for suggestions."
                ),
                OnboardingInformationView.Content(
                    icon: {
                        Image(systemName: "bell.fill")
                            .accessibilityHidden(true)
                    },
                    title: "Stay Motivated! 🎉",
                    description: "Get reminders and congrats to keep you on track!"
                )
            ],
            actionText: "Let's Get Started!",
            action: {
                onboardingNavigationPath.nextStep()
            }
        )
        .padding(.top, 24)
    }
}

#if DEBUG
#Preview {
    OnboardingStack {
        KidsOnboarding()
    }
}
#endif
