//
//  ExportPDFSheet.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/12/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import PDFKit
import SwiftUI
import TPPDF

struct ExportPDFSheet: View {
	@Environment(\.dismiss) private var dismiss
	@Environment(ActivityManager.self) private var activityManager
	@Environment(HydrationManager.self) private var hydrationManager
	@Environment(ProteinManager.self) private var proteinManager
	
	@State private var isSharing: Bool = false
	
	private var chartView: some View {
		VStack(spacing: 24) {
			DashboardChart(timeFrame: .week)
		}
		.padding()
	}
		
	var body: some View {
		NavigationStack {
			VStack {
				//				DashboardPDFView(image: image)
				ImageRendererPDFView()
			}
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading) {
					Button("Cancel") {
						dismiss()
					}
				}
				
				ToolbarItem(placement: .navigationBarTrailing) {
					Button(action: { isSharing = true }) {
						Label("Share", systemImage: "square.and.arrow.up")
					}
				}
			}
			.sheet(isPresented: $isSharing) {
				exportPDF()
			}
		}
	}
	
    private func exportPDF() -> some View {
        GeometryReader<ShareSheet> { geometry in
            let size = geometry.size
            let url: URL = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first ?? URL(fileURLWithPath: "")
                .appending(path: "Stanford360.pdf")
            
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
            
            return ShareSheet(activityItems: [url])
        }
    }
}

#Preview {
	ExportPDFSheet()
}
