//
//  ActivityComponentsView.swift
//  Stanford360
//
//  Created by Elsa Bismuth on 12/03/2025.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT

import SwiftUI

// MARK: - ActivityPickerView
struct ActivityPickerView: View {
    @Binding var selectedActivity: String
    
    // Allow customization of activities list when necessary
    var activities: [(activityName: String, iconName: String)] = [
        ("Walking", "figure.walk"),
        ("Running", "figure.run"),
        ("Dancing", "figure.dance"),
        ("Sports", "soccerball"),
        ("PE", "person.3"),
        ("Other", "questionmark")
    ]
    
    // Reusing the same column layout as SelectorView
    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(activities, id: \.activityName) { activity in
                activityItem(activity)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Activity Item View (reusing SelectorView's selectionItem pattern)
    private func activityItem(_ activity: (activityName: String, iconName: String)) -> some View {
        VStack(spacing: 6) {
            activityIcon(activity.iconName, name: activity.activityName)
            activityLabel(name: activity.activityName)
        }
        .frame(width: 65, height: 65)
        .padding()
        .background(activityBackground(activity))
        .shadow(radius: 2)
        .onTapGesture {
            selectedActivity = activity.activityName
        }
    }
    
    // MARK: - Activity Icon (following SelectorView's icon style)
    private func activityIcon(_ iconName: String, name: String) -> some View {
        Image(systemName: iconName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 40, height: 40)
            .foregroundColor(.primary)
            .accessibilityLabel(name)
    }
    
    // MARK: - Activity Label (similar to SelectorView)
    private func activityLabel(name: String) -> some View {
        Text(name)
            .font(.subheadline)
            .foregroundColor(.primary)
    }
    
    // MARK: - Background and Selection State (directly adapted from SelectorView)
    private func activityBackground(_ activity: (activityName: String, iconName: String)) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator), lineWidth: 1)
            if selectedActivity == activity.activityName {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.activityColor, lineWidth: 3)
            }
        }
    }
}

// MARK: - ActivityButtonView
struct ActivityButtonView: View {
    let activityName: String
    let iconName: String
    @Binding var selectedActivity: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .foregroundColor(.blue) // Change color as needed
                .accessibilityLabel(activityName)

            Text(activityName)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .frame(width: 65, height: 65)
        .padding()
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 12).fill(Color.white)
                if selectedActivity == activityName {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue, lineWidth: 3)
                }
            }
        )
        .shadow(radius: 2)
        .onTapGesture {
            selectedActivity = activityName
        }
    }
}

// MARK: - DatePickerView
struct DatePickerView: View {
    @Binding var selectedDate: Date
    var title: String = "When did you do it?"
    var dateRange: PartialRangeThrough<Date> = ...Date() // Default to past dates
    var displayComponents: DatePickerComponents = [.date]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            
            DatePicker(
                "Activity Date",
                selection: $selectedDate,
                in: dateRange,
                displayedComponents: displayComponents
            )
            .datePickerStyle(.compact)
        }
        .padding()
    }
}

// MARK: - MinutesInputView
struct MinutesInputView: View {
    @Binding var minutes: String
    var title: String = "How many minutes?"
    var goalText: String = "Goal: 60 minutes per day"
    @State private var sliderValue: Double = 0
    
    // Convert slider value to minutes in 10-minute increments
    private var sliderMinutes: Int {
        Int(sliderValue) * 10
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title and current value
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Text("\(sliderMinutes) min")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            
            // Simple slider with 10-minute increments
            HStack {
                Text("0")
                    .font(.caption)
                    .foregroundColor(.gray)
                Slider(value: $sliderValue, in: 0...6, step: 1)
                    .onChange(of: sliderValue) { _, _ in
                        minutes = "\(sliderMinutes)"
                    }
                Text("60")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            if !goalText.isEmpty {
                Text(goalText)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .onAppear {
            // Initialize slider from existing minutes value if not empty
            if let minutesInt = Int(minutes) {
                sliderValue = Double(min(minutesInt, 60)) / 10
            }
        }
    }
}

// MARK: - ActionButton
struct ActionButton: View {
    var title: String
    var action: () -> Void
    var isDisabled: Bool = false
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(.title3.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isDisabled ? Color.gray : Color.blue)
                )
        }
        .disabled(isDisabled)
        .padding()
    }
}

struct SaveActivityButton: View {
    @Binding var showingAddActivity: Bool
    var selectedActivity: String?
    var minutes: String?
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 10) {
            // Log button
            Button(action: {
                showingAddActivity = true
            }) {
                Text("Save My Activity! 🌟")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [
                                Color.blue,
                                Color.blue.opacity(0.8)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(radius: 3)
            }
            .padding(.horizontal)
            .accessibilityIdentifier("saveActivityButton")
            .accessibilityLabel("Save your activity")
        }
    }
}

// MARK: - ActivityComponentsView
/// Main container for activity-related UI components
struct ActivityComponentsView: View {
    var body: some View {
        Text("Activity Components")
            .font(.title)
    }
}

// MARK: - Previews
#Preview("Activity Components") {
    ActivityComponentsView()
}

#Preview("Activity Picker") {
    @Previewable @State var selectedActivity = "Walking"
    return ActivityPickerView(selectedActivity: $selectedActivity)
        .padding()
}

#Preview("Date Picker") {
    @Previewable @State var selectedDate = Date()
    return DatePickerView(selectedDate: $selectedDate)
        .padding()
}

#Preview("Minutes Input Slider") {
    @Previewable @State var minutes = "15"
    return MinutesInputView(minutes: $minutes)
}

#Preview("Action Button") {
    ActionButton(title: "Save Activity! 🌟", action: {})
        .padding()
}
