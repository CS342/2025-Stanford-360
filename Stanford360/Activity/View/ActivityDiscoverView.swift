//
//  ActivityDiscoverView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/10/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct ActivityDiscoverView: View {
    var body: some View {
        VStack {
            Image("activityRecs")
                .resizable()
                .scaledToFit()
                .frame(width: 350, height: 350)
                .padding()
                .accessibilityLabel("Activity Recommendations")
            
            if let videoURL = URL(string: "https://www.youtube.com/channel/UC0dS8MBi0l1sQoFjP1fmpMg/videos?view=0&sort=dd&shelf_id=0") {
                Link("Click here for videos with activity ideas!", destination: videoURL)
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding()
                    .accessibilityHint("Opens sports video website in browser")
            } else {
                Text("Click here for sport videos!")
                    .font(.headline)
                    .foregroundColor(.gray) // Dimmed to indicate it's not clickable
                    .padding()
            }
        }
    }
}

#Preview {
    ActivityDiscoverView()
}
