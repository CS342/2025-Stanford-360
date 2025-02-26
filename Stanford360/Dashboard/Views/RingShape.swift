//
//  RingShape.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 2/26/25.
//	Inspired by Frank Gia https://medium.com/@frankjia/creating-activity-rings-in-swiftui-11ef7d336676
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct RingShape: Shape {
	private var percent: Double
	private var startAngle: Double
	private let drawnClockwise: Bool
	
	// 2. This allows animations to run smoothly for percent values
	var animatableData: Double {
		get {
			percent
		}
		set {
			percent = newValue
		}
	}
	
	init(percent: Double = 100, startAngle: Double = -90, drawnClockwise: Bool = false) {
		self.percent = percent
		self.startAngle = startAngle
		self.drawnClockwise = drawnClockwise
	}
	
	// helper function to convert percent values to angles in degrees
	static func percentToAngle(percent: Double, startAngle: Double) -> Double {
		(percent / 100 * 360) + startAngle
	}
	
	// this draws a simple arc from the start angle to the end angle
	func path(in rect: CGRect) -> Path {
		let width = rect.width
		let height = rect.height
		let radius = min(width, height) / 2
		let center = CGPoint(x: width / 2, y: height / 2)
		let endAngle = Angle(degrees: RingShape.percentToAngle(percent: self.percent, startAngle: self.startAngle))
		
		return Path { path in
			path.addArc(
				center: center,
				radius: radius,
				startAngle: Angle(degrees: startAngle),
				endAngle: endAngle,
				clockwise: drawnClockwise
			)
		}
	}
}

#Preview {
	RingShape(percent: 60, startAngle: -90, drawnClockwise: false)
		.stroke(style: StrokeStyle(lineWidth: 50, lineCap: .round))
		.fill(Color.black)
		.frame(width: 300, height: 300)
}
