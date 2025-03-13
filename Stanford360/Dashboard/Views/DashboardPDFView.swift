//
//  DashboardPDFView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/13/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import PDFKit
import SwiftUI
import TPPDF

struct DashboardPDFView: UIViewRepresentable {
	var image: UIImage
	
	func makeUIView(context: Context) -> PDFView {
		let url = PDFDocument.generatePDF(image: image)
		let pdfView = PDFView()
		pdfView.document = PDFKit.PDFDocument(url: url)
		return pdfView
	}
	
	func updateUIView(_ uiView: PDFView, context: Context) { }
}

#Preview {
	DashboardPDFView(image: UIImage(systemName: "chart.xyaxis.line") ?? UIImage())
}
