//
//  DashboardWeeklyView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/2/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct DashboardWeeklyView: View {
	@State var showPDFExportSheet: Bool = false
	@State var size: CGSize?
	
    var body: some View {
		VStack {
			HStack {
				Spacer()
				ExportPDFButton(showingSheet: $showPDFExportSheet)
					.padding(.trailing, 20)
			}
			
			DashboardChartView(timeFrame: .week)
		}
		.sheet(isPresented: $showPDFExportSheet) {
			ExportPDFSheet()
		}
    }
}

#Preview {
    DashboardWeeklyView()
}
