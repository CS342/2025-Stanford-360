//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
//  DailyScheduleView.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 2/24/25.
//

import SwiftUI

struct DailyScheduleView: View {
	// MARK: - Properties
	var date: Date
	var taskStore: TaskStore
	@Binding var selectedTab: HomeView.Tabs
	
	// Toggle between showing all tasks or only remaining tasks
	@State private var showCompletedTasks = true
	
	// Format the date for display
	private var dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		return formatter
	}()
	
	// Get tasks for this specific date
	private var tasksForDate: [ScheduleTask] {
		taskStore.tasksForDate(date)
	}
	
	// Filtered tasks based on selection
	private var filteredTasks: [ScheduleTask] {
		if showCompletedTasks {
			return tasksForDate
		} else {
			return tasksForDate.filter { !$0.isCompleted }
		}
	}
	
	// Progress tracking
	var completedCount: Int {
		tasksForDate.filter { $0.isCompleted }.count
	}
	
	var totalCount: Int {
		tasksForDate.count
	}
	
	var progressPercentage: Double {
		guard totalCount > 0 else {
			return 0
		}
		
		return Double(completedCount) / Double(totalCount)
	}
	
	// MARK: - View Body
	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			headerView()
			filterToggleView()
			
			if tasksForDate.isEmpty {
				emptyStateView()
			} else {
				taskListView()
			}
		}
		.padding()
		.background(Color.white)
		.cornerRadius(12)
		.shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
	}
	
	// MARK: - Initializer
	init(date: Date, taskStore: TaskStore, selectedTab: Binding<HomeView.Tabs>) {
		self.date = date
		self.taskStore = taskStore
		self._selectedTab = selectedTab
	}
	
	// MARK: - Helper Views
	
	// Header with progress
	private func headerView() -> some View {
		HStack {
			VStack(alignment: .leading) {
				Text(dateFormatter.string(from: date))
					.font(.title3)
					.fontWeight(.bold)
				
				Text("\(completedCount)/\(totalCount) completed")
					.font(.subheadline)
					.foregroundColor(.gray)
			}
			
			Spacer()
			
			progressCircleView()
		}
	}
	
	// Progress circle view
	private func progressCircleView() -> some View {
		ZStack {
			Circle()
				.stroke(Color.gray.opacity(0.2), lineWidth: 4)
				.frame(width: 40, height: 40)
			
			Circle()
				.trim(from: 0, to: CGFloat(progressPercentage))
				.stroke(Color.teal, lineWidth: 4)
				.frame(width: 40, height: 40)
				.rotationEffect(.degrees(-90))
			
			Text("\(Int(progressPercentage * 100))%")
				.font(.caption)
				.fontWeight(.semibold)
		}
	}
	
	// Filter toggle view
	private func filterToggleView() -> some View {
		HStack {
			Text("View")
				.font(.subheadline)
				.foregroundColor(.gray)
			
			Picker("View", selection: $showCompletedTasks) {
				Text("All Tasks").tag(true)
				Text("Remaining").tag(false)
			}
			.pickerStyle(SegmentedPickerStyle())
		}
	}
	
	// Empty state view when no tasks exist for a date
	private func emptyStateView() -> some View {
		VStack(spacing: 12) {
			Image(systemName: "checkmark.circle")
				.font(.system(size: 40))
				.foregroundColor(.gray.opacity(0.5))
				.accessibilityLabel("No tasks")
			
			Text("No tasks scheduled")
				.font(.headline)
				.foregroundColor(.gray)
			
			Text("This day doesn't have any scheduled tasks.")
				.font(.subheadline)
				.foregroundColor(.gray.opacity(0.8))
				.multilineTextAlignment(.center)
		}
		.frame(maxWidth: .infinity)
		.padding(.vertical, 40)
	}
	
	// Task list view
	private func taskListView() -> some View {
		ScrollView {
			VStack(spacing: 12) {
				ForEach(filteredTasks) { task in
					taskRow(for: task)
				}
			}
			.animation(.easeInOut, value: showCompletedTasks)
		}
	}
	
	// Individual task row
	private func taskRow(for task: ScheduleTask) -> some View {
		// Determine if the task is navigable
		let isNavigable = task.navigationType != nil
		
		return Button(action: {
			// Handle navigation if task has a navigation type
			if let navigationType = task.navigationType {
				selectedTab = navigationType.tabValue
			}
		}) {
			HStack {
				taskCategoryIcon(for: task)
				taskDetails(for: task, isNavigable: isNavigable)
				Spacer()
				taskCheckbox(for: task)
			}
			.padding(.vertical, 8)
			.padding(.horizontal, 12)
			.background(Color.gray.opacity(0.05))
			.cornerRadius(10)
		}
		// Important: only make the button active if there's a navigation type
		.disabled(task.navigationType == nil)
	}
	
	// Task category icon
	private func taskCategoryIcon(for task: ScheduleTask) -> some View {
		ZStack {
			Circle()
				.fill(task.category.color.opacity(0.2))
				.frame(width: 36, height: 36)
			
			Image(systemName: task.category.icon)
				.foregroundColor(task.category.color)
				.accessibilityLabel(task.category.rawValue)
		}
	}
	
	// Task details with navigation indicator if applicable
	private func taskDetails(for task: ScheduleTask, isNavigable: Bool) -> some View {
		HStack {
			VStack(alignment: .leading, spacing: 2) {
				Text(task.title)
					.font(.body)
					.foregroundColor(task.isCompleted ? .gray : .primary)
					.strikethrough(task.isCompleted)
				
				Text(task.time)
					.font(.caption)
					.foregroundColor(.gray)
			}
			
			if isNavigable {
    				Image(systemName: "chevron.right")
    					.font(.caption)
    					.foregroundColor(.gray)
    					.accessibilityLabel("Navigate to task details")
					.padding(.leading, 4)
			}
		}
		.padding(.leading, 8)
	}
	
	// Task checkbox that stops event propagation
	private func taskCheckbox(for task: ScheduleTask) -> some View {
		Button(action: {
			taskStore.toggleTaskCompletion(taskId: task.id)
		}) {
			ZStack {
				Circle()
					.stroke(Color.gray.opacity(0.3), lineWidth: 1.5)
					.frame(width: 24, height: 24)
				
				if task.isCompleted {
					Circle()
						.fill(Color.teal)
						.frame(width: 24, height: 24)
					
    					Image(systemName: "checkmark")
    						.font(.system(size: 12, weight: .bold))
    						.foregroundColor(.white)
    						.accessibilityLabel("Task completed checkmark")
				}
			}
		}
		// Important: This prevents the button action from triggering the parent button's action
		.buttonStyle(BorderlessButtonStyle())
	}
}

#Preview {
	@Previewable @State var selectedTab = HomeView.Tabs.dashboard
	@Previewable @State var date = Date.now
	@Previewable @State var taskStore = TaskStore()
	
	DailyScheduleView(date: date, taskStore: taskStore, selectedTab: $selectedTab)
}
