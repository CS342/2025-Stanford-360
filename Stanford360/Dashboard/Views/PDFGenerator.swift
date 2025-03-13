//
//  PDFGenerator.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 3/13/25.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import TPPDF
import UIKit

extension PDFDocument {
	static func generatePDF(image: UIImage) -> URL {
		let document = TPPDF.PDFDocument(format: .a4)
		let newWidth: CGFloat = 300
		let newHeight: CGFloat = 300

		
		let imageElement = PDFImage(
			image: image,
			size: CGSize(width: newWidth, height: newHeight),
			quality: 1
		)
		imageElement.sizeFit = .width
		document.add(.contentLeft, image: imageElement)
		
		// generate the pdf
		let date = Date().formatted(date: .numeric, time: .omitted).replacingOccurrences(of: "/", with: "-")
		let filename = "\(date) Stanford 360 Details.pdf"
		let generator = PDFGenerator(document: document)
		let url = try? generator.generateURL(filename: filename)
		return url ?? URL(fileURLWithPath: "")
	}
}
