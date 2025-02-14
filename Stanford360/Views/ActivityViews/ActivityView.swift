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
    @State private var activityManager = ActivityManager()
    @State private var showingAddActivity = false
    @State private var selectedTimeFrame: TimeFrame = .today
    
    @Environment(Stanford360Standard.self) private var standard
    
    var body: some View {
        NavigationStack {
            content
        }
    }
    
    // Extracted content to reduce body closure length
    private var content: some View {
        ZStack {
            mainActivityContent
            addActivityButton
        }
        .navigationTitle("My Active Journey 🏃‍♂️")
        .sheet(isPresented: $showingAddActivity) {
            AddActivitySheet(activityManager: activityManager)
        }
    }
    
    // Extracted main activity content
    private var mainActivityContent: some View {
        VStack(spacing: 20) {
            timeFramePicker
            motivationText
            
            ActivityTimeFrameView(
                timeFrame: selectedTimeFrame,
                activityManager: activityManager
            )
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
