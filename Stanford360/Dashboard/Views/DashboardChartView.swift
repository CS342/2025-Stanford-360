//
//  DashboardChartView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/2/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct DashboardChartView: View {
	var timeFrame: TimeFrame
	
	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			Text(timeFrame.title)
				.font(.headline)
				.padding(.horizontal)
				.foregroundColor(Color.textPrimary)
			DashboardChart(timeFrame: timeFrame)
			
			Button {
				exportPDF()
			} label: {
				Label("PDF", systemImage: "doc.plaintext")
			}
			.buttonStyle(.borderedProminent)
			
			Spacer()
		}
		.padding(.top, 20)
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
	}
	
	private func exportPDF() {
		guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
			return
		}
		
		let renderedUrl = documentDirectory.appending(path: "linechart.pdf")
		
		let renderer = ImageRenderer(content:
										VStack {
			Text(timeFrame.title)
				.font(.headline)
				.padding(.horizontal)
			
			DashboardChart(timeFrame: timeFrame)
		})
		
		
		if let consumer = CGDataConsumer(url: renderedUrl as CFURL),
		   let pdfContext = CGContext(consumer: consumer, mediaBox: nil, nil) {
			renderer.render { size, renderer in
				let options: [CFString: Any] = [
					kCGPDFContextMediaBox: CGRect(origin: .zero, size: size)
				]
				
				pdfContext.beginPDFPage(options as CFDictionary)
				
				renderer(pdfContext)
				pdfContext.endPDFPage()
				pdfContext.closePDF()
			}
		}
		
		print("Saving PDF to \(renderedUrl.path())")
	}
}

#Preview {
	DashboardChartView(timeFrame: .month)
}
