//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
////
////  InfiniteDayTimelineView.swift
////  Stanford360
////
////  Created by Kelly Bonilla Guzmán on 2/24/25.
////
//
// import SwiftUI
//
//// A more comprehensive implementation with continuous scrolling
// struct InfiniteTimelineView: View {
//	// Store date information
//	@State private var visibleDates: [Date] = []
//	@State private var centerDate = Date()
//	@State private var scrollTarget: Int? = nil
//
//	// Control virtual pagination
//	@State private var pageIndex = 0
//	private let itemsPerPage = 30
//	private let preloadThreshold = 10
//
//	// Layout constants
//	private let dayItemWidth: CGFloat = 50
//	private let dayItemSpacing: CGFloat = 10
//
//	// Lifecycle and tracking
//	@State private var isInitialized = false
//	@State private var scrollOffset: CGFloat = 0
//
//	var body: some View {
//		VStack {
//			Text("Current Date: \(formattedDate(centerDate))")
//				.font(.subheadline)
//				.padding(.bottom, 4)
//
//			GeometryReader { geometry in
//				ScrollView(.horizontal, showsIndicators: false) {
//					ScrollViewReader { proxy in
//						LazyHStack(spacing: dayItemSpacing) {
//							ForEach(Array(visibleDates.enumerated()), id: \.offset) { index, date in
//								dayView(for: date, isCurrent: isSameDay(date, Date()))
//									.id(index)
//									.frame(width: dayItemWidth)
//							}
//						}
//						.padding(.horizontal, geometry.size.width / 2 - dayItemWidth / 2)
//						.background(
//							GeometryReader { scrollGeometry in
//								Color.clear.preference(
//									key: ScrollOffsetPreferenceKey.self,
//									value: scrollGeometry.frame(in: .named("scroll")).minX
//								)
//							}
//						)
//						.onAppear {
//							if !isInitialized {
//								initializeDates()
//								isInitialized = true
//
//								// Scroll to center (today) when first appearing
//								DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//									withAnimation {
//										scrollTarget = visibleDates.count / 2
//										proxy.scrollTo(scrollTarget, anchor: .center)
//									}
//								}
//							}
//						}
//						.onChange(of: scrollTarget) { target in
//							if let target = target {
//								withAnimation {
//									proxy.scrollTo(target, anchor: .center)
//								}
//							}
//						}
//					}
//				}
//				.coordinateSpace(name: "scroll")
//				.onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
//					handleScroll(offset: value, width: geometry.size.width)
//				}
//			}
//		}
//	}
//
//	private func dayView(for date: Date, isCurrent: Bool) -> some View {
//		let calendar = Calendar.current
//		let weekday = calendar.component(.weekday, from: date)
//		let dayNum = calendar.component(.day, from: date)
//		let isPast = date < Date().startOfDay
//		let isToday = calendar.isDateInToday(date)
//
//		return VStack(spacing: 4) {
//			ZStack {
//				Circle()
//					.fill(isPast ? Color.teal : Color.gray.opacity(0.2))
//					.frame(width: 36, height: 36)
//
//				if isToday {
//					Circle()
//						.trim(from: 0, to: 0.75)
//						.stroke(Color.teal, lineWidth: 2)
//						.frame(width: 36, height: 36)
//						.rotationEffect(.degrees(-90))
//				}
//
//				if isPast {
//					Image(systemName: "checkmark")
//						.foregroundColor(.white)
//						.font(.system(size: 12, weight: .bold))
//				} else {
//					Text("\(dayNum)")
//						.font(.system(size: 14, weight: .medium))
//						.foregroundColor(isToday ? .teal : .primary)
//				}
//			}
//
//			Text(weekdayAbbreviation(for: weekday))
//				.font(.caption)
//				.foregroundColor(isToday ? .teal : .gray)
//
//			if isToday {
//				Circle()
//					.fill(Color.teal)
//					.frame(width: 4, height: 4)
//			}
//		}
//	}
//
//	private func initializeDates() {
//		let calendar = Calendar.current
//		let today = Date()
//		let startDate = calendar.date(byAdding: .day, value: -itemsPerPage/2, to: today)!
//
//		// Generate initial set of dates
//		visibleDates = (0..<itemsPerPage).map { offset in
//			calendar.date(byAdding: .day, value: offset, to: startDate)!
//		}
//	}
//
//	private func handleScroll(offset: CGFloat, width: CGFloat) {
//		let calendar = Calendar.current
//
//		// Calculate the center item based on scroll position
//		let approximateItem = -offset / (dayItemWidth + dayItemSpacing)
//		let centerItem = Int(approximateItem.rounded())
//
//		if centerItem >= 0 && centerItem < visibleDates.count {
//			// Update the center date when scrolling
//			centerDate = visibleDates[centerItem]
//
//			// Check if we need to load more dates (forward)
//			if centerItem > visibleDates.count - preloadThreshold {
//				let lastDate = visibleDates.last!
//				let newDates = (1...preloadThreshold).map { offset in
//					calendar.date(byAdding: .day, value: offset, to: lastDate)!
//				}
//				visibleDates.append(contentsOf: newDates)
//			}
//
//			// Check if we need to load more dates (backward)
//			if centerItem < preloadThreshold {
//				let firstDate = visibleDates.first!
//				let newDates = (1...preloadThreshold).map { offset in
//					calendar.date(byAdding: .day, value: -offset, to: firstDate)!
//				}.reversed()
//				visibleDates.insert(contentsOf: newDates, at: 0)
//
//				// Adjust scroll target to maintain position after inserting items
//				scrollTarget = centerItem + preloadThreshold
//			}
//		}
//	}
//
//	private func weekdayAbbreviation(for weekday: Int) -> String {
//		let weekdays = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
//		return weekdays[weekday - 1]
//	}
//
//	private func formattedDate(_ date: Date) -> String {
//		let formatter = DateFormatter()
//		formatter.dateStyle = .medium
//		return formatter.string(from: date)
//	}
//
//	private func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
//		return Calendar.current.isDate(date1, inSameDayAs: date2)
//	}
// }
//
//// Extension to get start of day
// extension Date {
//	var startOfDay: Date {
//		return Calendar.current.startOfDay(for: self)
//	}
// }
//
//// Preference key to track scroll position
// struct ScrollOffsetPreferenceKey: PreferenceKey {
//	static var defaultValue: CGFloat = 0
//	static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
//		value = nextValue()
//	}
// }
//
////
////// Main view that incorporates the timeline
//// struct ContentView: View {
////	var body: some View {
////		VStack(spacing: 20) {
////			Text("Fitness Tracker")
////				.font(.title)
////				.fontWeight(.bold)
////
////			// Simple timeline that can scroll but is not infinite
////			DayTimelineView()
////				.frame(height: 80)
////				.padding(.vertical)
////				.background(Color.gray.opacity(0.1))
////				.cornerRadius(12)
////
////			Divider()
////
////			// More advanced infinite timeline with preloading
////			InfiniteTimelineView()
////				.frame(height: 80)
////				.padding(.vertical)
////				.background(Color.gray.opacity(0.1))
////				.cornerRadius(12)
////				.padding(.bottom)
////
////			Spacer()
////		}
////		.padding()
////	}
//// }
////
//// struct ContentView_Previews: PreviewProvider {
////	static var previews: some View {
////		ContentView()
////	}
//// }
//
// #Preview {
//    InfiniteDayTimelineView()
// }
