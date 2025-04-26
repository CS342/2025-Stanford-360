//
//  LLMLocalOnboardingDownloadView.swift
//  Stanford360
//
//  Created by jiayu chang on 3/11/25.
//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

 import SpeziLLM
 import SpeziLLMLocal
 import SpeziLLMLocalDownload
 import SpeziOnboarding
 import SwiftUI

 struct LLMLocalOnboardingDownloadView: View {
    @Environment(OnboardingNavigationPath.self) private var onboardingNavigationPath


    var body: some View {
        LLMLocalDownloadView(
            model: .llama3_2_1B_4bit,
            downloadDescription: "The Llama3 1B model will be downloaded"
        ) {
            onboardingNavigationPath.nextStep()
        }
    }
 }
