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
import SwiftUI

/// Simple UI for tracking kids' activity.
struct ActivityView: View {
    // Enum moved to the top of the type contents
    enum TimeFrame {
        case today, week, month
    }
    
    // State properties grouped together
    @Environment(ActivityManager.self) private var activityManager
    @State private var showingAddActivity = false
    @State private var selectedTimeFrame: TimeFrame = .today
    @State private var showHealthKitAlert = false
    
//    @Environment(Stanford360Standard.self) private var standard
    
    var body: some View {
        NavigationView {
            content
        }
        .task {
            // Replace await with proper async operation if needed
            await activityManager.loadActivities()
        }
    }
    
    // Extracted content to reduce body closure length
    private var content: some View {
        ZStack {
            VStack(spacing: 20) {
                if !activityManager.healthKitManager.isHealthKitAuthorized {
                    healthKitWarningBanner
                }
                
                timeFramePicker
                motivationText
                
                ActivityTimeFrameView(
                    timeFrame: selectedTimeFrame,
                    activityManager: activityManager
                )
            }
            addActivityButton
        }
        .navigationTitle("My Active Journey 🏃‍♂️")
        .sheet(isPresented: $showingAddActivity) {
            AddActivitySheet(activityManager: activityManager)
        }
        .onAppear {
            Task {
                // Request HealthKit authorization when view appears
                 activityManager.setupHealthKit()
            }
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
        .padding(.horizontal, 16)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(10)
        .onTapGesture {
            showHealthKitAlert = true
        }
    }
    
    // Extracted time frame picker
    private var timeFramePicker: some View {
        Picker("Time Frame", selection: $selectedTimeFrame) {
            Text("Today").tag(TimeFrame.today)
            Text("This Week").tag(TimeFrame.week)
            Text("This Month").tag(TimeFrame.month)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal)
    }
    
    // Extracted motivation text
    private var motivationText: some View {
        Text(activityManager.triggerMotivation())
            .font(.headline)
            .foregroundColor(.blue)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.blue.opacity(0.1))
            )
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
}

#Preview {
    ActivityView()
        .environment(Stanford360Standard())
}
