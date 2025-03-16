//
//  ImageRendererPDFView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/13/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct ImageRendererPDFView: View {
	@Environment(ActivityManager.self) private var activityManager
	@Environment(HydrationManager.self) private var hydrationManager
	@Environment(ProteinManager.self) private var proteinManager
		
	private var chartView: some View {
		VStack(spacing: 24) {
			DashboardChart(timeFrame: .week)
		}
		.padding()
	}
	
	var body: some View {
		GeometryReader { geometry in
			let size = geometry.size
			chartView
				.onAppear {
					guard let documentsDirectory = FileManager.default
						.urls(for: .documentDirectory, in: .userDomainMask)
						.first else {
						print("Failed to access documents directory")
						return
					}
					
					let url = documentsDirectory.appending(path: "Stanford360.pdf")
					
					let renderer = ImageRenderer(
						content: chartView
							.frame(width: size.width, height: size.height, alignment: .center)
							.environment(activityManager)
							.environment(hydrationManager)
							.environment(proteinManager)
					)
					
					// Generating PDF
					if let consumer = CGDataConsumer(url: url as CFURL), let context = CGContext(consumer: consumer, mediaBox: nil, nil) {
						renderer.render { size, renderer in
							var mediaBox = CGRect(origin: .zero, size: size)
							// Drawing PDF
							context.beginPage(mediaBox: &mediaBox)
							renderer(context)
							context.endPDFPage()
							context.closePDF()
						}
					}
				}
		}
	}
}

#Preview {
	ImageRendererPDFView()
}
