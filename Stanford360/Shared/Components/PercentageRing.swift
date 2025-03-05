//
//  ActivityRing.swift
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

struct PercentageRing: View {
	private static let ShadowColor: Color = .black.opacity(0.2)
	private static let ShadowRadius: CGFloat = 5
	private static let ShadowOffsetMultiplier: CGFloat = ShadowRadius + 2
	
	private let currentValue: Int
	private let maxValue: Int
	private let unitLabel: String
	private let iconName: String
	private let iconSize: CGFloat
	private let ringWidth: CGFloat
	private let backgroundColor: Color
	private let foregroundColors: [Color]
	private let showProgressTextInCenter: Bool
	private let startAngle: Double = -90
	
	private var percent: Double {
		Double(currentValue) / Double(maxValue) * 100
	}
	
	private var gradientStartAngle: Double {
		self.percent >= 100 ? relativePercentageAngle - 360 : startAngle
	}
	
	private var absolutePercentageAngle: Double {
		RingShape.percentToAngle(percent: self.percent, startAngle: 0)
	}
	private var relativePercentageAngle: Double {
		// Take into account the startAngle
		absolutePercentageAngle + startAngle
	}
	
	private var lastGradientColor: Color {
		self.foregroundColors.last ?? .black
	}
	
	private var ringGradient: AngularGradient {
		AngularGradient(
			gradient: Gradient(colors: self.foregroundColors),
			center: .center,
			startAngle: Angle(degrees: self.gradientStartAngle),
			endAngle: Angle(degrees: relativePercentageAngle)
		)
	}
	
	var body: some View {
		// Wrap view in a GeometryReader so that the view has access to its parent size
		GeometryReader { geometry in
			ZStack {
				// background ring
				RingShape()
					.stroke(style: StrokeStyle(lineWidth: self.ringWidth))
					.fill(self.backgroundColor)
				
				// foreground ring
				RingShape(percent: self.percent, startAngle: self.startAngle)
					.stroke(style: StrokeStyle(lineWidth: self.ringWidth, lineCap: .round))
					.fill(self.ringGradient)
				
				// shadow to show progress for percentages over 100%
				if self.getShowShadow(frame: geometry.size) {
					shadow(geometry: geometry)
				}
				
				// add icon at the end of the ring
				Image(systemName: iconName)
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: self.iconSize, height: self.iconSize)
					.foregroundColor(.white)
					.offset(
						x: self.getEndCircleLocation(frame: geometry.size).0,
						y: self.getEndCircleLocation(frame: geometry.size).1
					)
					.zIndex(1)
					.accessibilityLabel(iconName)
				
				// optionally show progress text in center
				if showProgressTextInCenter {
					progressTextInCenter(geometry: geometry)
				}
			}
		}
		// Padding to ensure that the entire ring fits within the view size allocated
		.padding(self.ringWidth / 2)
	}
	
	init(
		currentValue: Int,
		maxValue: Int,
		iconName: String,
		ringWidth: CGFloat,
		backgroundColor: Color,
		foregroundColors: [Color],
		unitLabel: String = "",
		iconSize: CGFloat = 24,
		showProgressTextInCenter: Bool = false
	) {
		self.currentValue = currentValue
		self.maxValue = maxValue
		self.unitLabel = unitLabel
		self.iconName = iconName
		self.iconSize = iconSize
		self.ringWidth = ringWidth
		self.backgroundColor = backgroundColor
		self.foregroundColors = foregroundColors
		self.showProgressTextInCenter = showProgressTextInCenter
	}
	
	private func shadow(geometry: GeometryProxy) -> some View {
		Circle()
			.fill(self.lastGradientColor)
			.frame(width: self.ringWidth, height: self.ringWidth, alignment: .center)
			.offset(
				x: self.getEndCircleLocation(frame: geometry.size).0,
				y: self.getEndCircleLocation(frame: geometry.size).1
			)
			.shadow(
				color: PercentageRing.ShadowColor,
				radius: PercentageRing.ShadowRadius,
				x: self.getEndCircleShadowOffset().0,
				y: self.getEndCircleShadowOffset().1
			)
	}
	
	private func progressTextInCenter(geometry: GeometryProxy) -> some View {
		VStack(spacing: 4) {
			Text("\(currentValue)/\(maxValue)")
				.font(.system(size: min(geometry.size.width, geometry.size.height) * 0.2, weight: .bold, design: .rounded))
				.minimumScaleFactor(0.5)
			
			Text(unitLabel)
				.font(.system(size: min(geometry.size.width, geometry.size.height) * 0.1, design: .rounded))
				.foregroundColor(.secondary)
		}
		.padding()
	}
	
	// Returns the (x, y) location of the offset
	private func getEndCircleLocation(frame: CGSize) -> (CGFloat, CGFloat) {
		// Get angle of the end circle with respect to the start angle
		let angleOfEndInRadians: Double = relativePercentageAngle.toRadians()
		let offsetRadius = min(frame.width, frame.height) / 2
		return (offsetRadius * cos(angleOfEndInRadians).toCGFloat(),
				offsetRadius * sin(angleOfEndInRadians).toCGFloat())
	}
	
	private func getEndCircleShadowOffset() -> (CGFloat, CGFloat) {
		let angleForOffset = absolutePercentageAngle + (self.startAngle + 90)
		let angleForOffsetInRadians = angleForOffset.toRadians()
		let relativeXOffset = cos(angleForOffsetInRadians)
		let relativeYOffset = sin(angleForOffsetInRadians)
		let xOffset = relativeXOffset.toCGFloat() * PercentageRing.ShadowOffsetMultiplier
		let yOffset = relativeYOffset.toCGFloat() * PercentageRing.ShadowOffsetMultiplier
		return (xOffset, yOffset)
	}
	
	private func getShowShadow(frame: CGSize) -> Bool {
		let circleRadius = min(frame.width, frame.height) / 2
		let remainingAngleInRadians = (360 - absolutePercentageAngle).toRadians().toCGFloat()
		if self.percent >= 100 {
			return true
		} else if circleRadius * remainingAngleInRadians <= self.ringWidth {
			return true
		}
		
		return false
	}
}

extension Double {
	func toRadians() -> Double {
		self * Double.pi / 180
	}
	func toCGFloat() -> CGFloat {
		CGFloat(self)
	}
}

#Preview {
	PercentageRing(
		currentValue: 40,
		maxValue: 60,
		iconName: "figure.walk",
		ringWidth: 50,
		backgroundColor: .activityColorBackground,
		foregroundColors: [.activityColor, .activityColorGradient],
		iconSize: 28
	)
}
