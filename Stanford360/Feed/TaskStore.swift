//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
//  TaskStore.swift
//  Stanford360
//
//  Created by Kelly Bonilla Guzmán on 2/24/25.
//

import Foundation

@Observable
class TaskStore {
	var allTasks: [ScheduleTask] = []
	
	// Initialize with sample data
	init() {
		// Today's tasks
		let today = Date()
		let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today) ?? today
		let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today
		
		// Sample tasks for today
		allTasks.append(contentsOf: [
			ScheduleTask(title: "Eat Breakfast", time: "8:00 AM", category: .meal, isCompleted: false, date: today, navigationType: .protein),
			ScheduleTask(title: "Take Medication", time: "9:00 AM", category: .medication, isCompleted: false, date: today),
			ScheduleTask(title: "Morning Walk", time: "10:00 AM", category: .exercise, isCompleted: false, date: today, navigationType: .activity),
			ScheduleTask(title: "Drink Water", time: "11:00 AM", category: .water, isCompleted: false, date: today, navigationType: .hydration),
			ScheduleTask(title: "Eat Lunch", time: "12:30 PM", category: .meal, isCompleted: false, date: today, navigationType: .protein),
			ScheduleTask(title: "Take Medication", time: "2:00 PM", category: .medication, isCompleted: false, date: today),
			ScheduleTask(title: "Eat Dinner", time: "7:00 PM", category: .meal, isCompleted: false, date: today, navigationType: .protein)
		])
		
		// Sample tasks for yesterday (some completed)
		allTasks.append(contentsOf: [
			ScheduleTask(title: "Eat Breakfast", time: "8:00 AM", category: .meal, isCompleted: true, date: yesterday, navigationType: .protein),
			ScheduleTask(title: "Take Medication", time: "9:00 AM", category: .medication, isCompleted: true, date: yesterday),
			ScheduleTask(title: "Morning Walk", time: "10:00 AM", category: .exercise, isCompleted: true, date: yesterday, navigationType: .activity),
			ScheduleTask(title: "Drink Water", time: "11:00 AM", category: .water, isCompleted: true, date: yesterday, navigationType: .hydration),
			ScheduleTask(title: "Eat Lunch", time: "12:30 PM", category: .meal, isCompleted: true, date: yesterday, navigationType: .protein),
			ScheduleTask(title: "Take Medication", time: "2:00 PM", category: .medication, isCompleted: true, date: yesterday),
			ScheduleTask(title: "Eat Dinner", time: "7:00 PM", category: .meal, isCompleted: false, date: yesterday, navigationType: .protein)
		])
		
		// Sample tasks for tomorrow (none completed)
		allTasks.append(contentsOf: [
			ScheduleTask(title: "Eat Breakfast", time: "8:00 AM", category: .meal, isCompleted: false, date: tomorrow, navigationType: .protein),
			ScheduleTask(title: "Take Medication", time: "9:00 AM", category: .medication, isCompleted: false, date: tomorrow),
			ScheduleTask(title: "Morning Walk", time: "10:00 AM", category: .exercise, isCompleted: false, date: tomorrow, navigationType: .activity),
			ScheduleTask(title: "Drink Water", time: "11:00 AM", category: .water, isCompleted: false, date: tomorrow, navigationType: .hydration),
			ScheduleTask(title: "Eat Lunch", time: "12:30 PM", category: .meal, isCompleted: false, date: tomorrow, navigationType: .protein),
			ScheduleTask(title: "Take Medication", time: "2:00 PM", category: .medication, isCompleted: false, date: tomorrow),
			ScheduleTask(title: "Eat Dinner", time: "7:00 PM", category: .meal, isCompleted: false, date: tomorrow, navigationType: .protein)
		])
	}
	
	// Get tasks for a specific date
	func tasksForDate(_ date: Date) -> [ScheduleTask] {
		allTasks.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
	}
	
	// Check if all tasks for a specific date are completed
	func areAllTasksCompletedForDate(_ date: Date) -> Bool {
		let tasks = tasksForDate(date)
		return !tasks.isEmpty && tasks.allSatisfy { $0.isCompleted }
	}
	
	// Toggle task completion status
	func toggleTaskCompletion(taskId: UUID) {
		if let index = allTasks.firstIndex(where: { $0.id == taskId }) {
			allTasks[index].isCompleted.toggle()
		}
	}
}
