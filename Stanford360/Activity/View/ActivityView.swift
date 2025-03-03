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
	@Environment(PatientManager.self) private var patientManager
    @Environment(Account.self) private var account: Account?
	
	// State properties grouped together
    @State private var showingAddActivity = false
    @State private var showHealthKitAlert = false
    @Binding private var presentingAccount: Bool
    
    @Environment(Stanford360Standard.self) internal var standard

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
				
				AddButton(showingAddItem: $showingAddActivity, imageAccessibilityLabel: "Add Activity Button")
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
        .task {
			await loadActivities()
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
    
    // Extracted add activity button
    private var addActivityButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: { showingAddActivity = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 56))
                        .foregroundColor(.blue)
                        .shadow(radius: 3)
                        .background(Circle().fill(.white))
                        .accessibilityLabel("Add Activity Button")
                }
                .padding([.trailing, .bottom], 25)
            }
        }
    }
	
	init(presentingAccount: Binding<Bool>) {
		self._presentingAccount = presentingAccount
	}
	
	func loadActivities() async {
		activityManager.activities = await standard.fetchActivities()
		
		// update patient's activities
		patientManager.updateActivityMinutes(activityManager.getTodayTotalMinutes())
		
		// fetch from healthkit
		do {
			try await healthKitManager.requestAuthorization()
			await syncHealthKitData()
		} catch {
			print("Failed to setup HealthKit: \(error.localizedDescription)")
		}
	}
    
    // Retrieve data from HealthKit and convert it to an Activity
    func syncHealthKitData() async {
        do {
            // First check if HealthKit is authorized
            if !healthKitManager.isHealthKitAuthorized {
                try await healthKitManager.requestAuthorization()
            }
            
            // Use fetchAndConvertHealthKitData to properly convert steps to minutes
            let healthKitActivity = try await healthKitManager.fetchAndConvertHealthKitData(for: Date())
            
            print("HealthKit data fetched: \(healthKitActivity.activeMinutes) minutes, \(healthKitActivity.steps) steps")
            
            // Remove any existing HealthKit activities for today - use consistent activity type
            let today = Calendar.current.startOfDay(for: Date())
            activityManager.activities.removeAll { activity in
                activity.activityType == "HealthKit Import" &&
                Calendar.current.startOfDay(for: activity.date) == today
            }
            
            // Only add if there are actual activities recorded
            if healthKitActivity.activeMinutes > 0 || healthKitActivity.steps > 0 {
                print("Adding HealthKit activity with \(healthKitActivity.activeMinutes) minutes")
                // Make sure we're not adding this activity to HealthKit again
                var activityCopy = healthKitActivity
                activityCopy.activityType = "HealthKit Import"
                activityManager.activities.append(activityCopy)
                activityManager.saveToStorage()
            } else {
                print("No significant HealthKit activity found for today")
            }
        } catch {
            print("Failed to sync HealthKit data: \(error.localizedDescription)")
        }
    }
}

#Preview {
    @Previewable @State var presentingAccount = false

    ActivityView(presentingAccount: $presentingAccount)
        .environment(Stanford360Standard())
}
