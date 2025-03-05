//
//  ActivityView.swift
//  Stanford360
//
//  Created by Elsa Bismuth on 30/01/2025.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT

import Charts
import FirebaseAuth
@_spi(TestingSupport) import SpeziAccount
import SwiftUI

/// Simple UI for tracking kids' activity.
struct ActivityView: View {
    @Environment(ActivityManager.self) private var activityManager
    @Environment(HealthKitManager.self) private var healthKitManager
    @Environment(Account.self) private var account: Account?
    
    // State properties grouped together
    @State private var showingAddActivity = false
    @State private var showingInfo = false
    @State private var showHealthKitAlert = false
    @Binding private var presentingAccount: Bool
        
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 20) {
                    if !healthKitManager.isHealthKitAuthorized {
                        healthKitWarningBanner
                    }
                    
                    ActivityTimeFrameView(
                        activityManager: activityManager
                    )
                }
                
                buttons
            }
            .navigationTitle("My Active Journey 🏃‍♂️")
            .toolbar {
                if account != nil {
                    AccountButton(isPresented: $presentingAccount)
                }
            }
            .sheet(isPresented: $showingAddActivity) {
                AddActivitySheet()
            }
            .sheet(isPresented: $showingInfo) {
                ActivityRecsSheet()
            }
            .alert("HealthKit Access Required", isPresented: $showHealthKitAlert) {
                Button("Open Settings", role: .none) {
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL)
                    }
                }
                Button("Continue Without HealthKit", role: .cancel) { }
            } message: {
                Text("Enable HealthKit in Settings to auto-track steps, or log activities manually.")
            }
        }
    }
    
    private var buttons: some View {
        ZStack {
            HStack {
                IconButton(
                    showingAddItem: $showingInfo,
                    imageName: "questionmark.circle.fill",
                    imageAccessibilityLabel: "Activity Recommendation Button",
                    color: .green
                )
                .padding(.trailing, 70)
                Spacer()
            }
            
            HStack {
                Spacer()
                IconButton(
                    showingAddItem: $showingAddActivity,
                    imageName: "plus.circle.fill",
                    imageAccessibilityLabel: "Add Activity Button",
                    color: .blue
                )
                .padding(.trailing, 10)
            }
        }
    }
    
    // Extracted health kit warning banner
    private var healthKitWarningBanner: some View {
        VStack {
            Text("HealthKit Access Not Available")
                .font(.headline)
                .foregroundColor(.orange)
            Text("Activities must be logged manually")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(10)
        .onTapGesture {
            showHealthKitAlert = true
        }
    }
	
	init(presentingAccount: Binding<Bool>) {
		self._presentingAccount = presentingAccount
	}
}

#Preview {
    @Previewable @State var presentingAccount = false
    
    ActivityView(presentingAccount: $presentingAccount)
        .environment(Stanford360Standard())
}
