//
//  HealthKitManager.swift
//  Stanford360
//
//  Created by Elsa Bismuth on 13/02/2025.
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT

import Foundation
import HealthKit

enum HealthKitError: Error {
//    case authorizationDenied
    case dateCalculationFailed
    case fetchingStepsFailed
    case fetchingActiveMinutesFailed
    case fetchingCaloriesFailed
}

@MainActor
@Observable
class HealthKitManager {
    let healthStore: HKHealthStore
    var isHealthKitAuthorized = false
    private var healthKitObserver: Any?
    
    private let healthKitTypes: (read: Set<HKSampleType>, write: Set<HKSampleType>) = {
        guard let steps = HKObjectType.quantityType(forIdentifier: .stepCount),
              let calories = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
              let exercise = HKObjectType.quantityType(forIdentifier: .appleExerciseTime) else {
            fatalError("These HealthKit types should be available on iOS")
        }
        
        return (
            read: [steps, calories, exercise],
            write: [steps, calories]
        )
    }()
    
    init(healthStore: HKHealthStore = HKHealthStore()) {
       self.healthStore = healthStore
    }
   
    func requestAuthorization() async throws {
        try await healthStore.requestAuthorization(toShare: healthKitTypes.write, read: healthKitTypes.read)
        isHealthKitAuthorized = true
    }
    
    func readDailyActivity(for date: Date) async throws -> HealthKitActivity {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date)
        guard let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) else {
            throw HealthKitError.dateCalculationFailed
        }
        
        async let steps = fetchSteps(startDate: startDate, endDate: endDate)
        async let activeMinutes = fetchActiveMinutes(startDate: startDate, endDate: endDate)
        async let calories = fetchCalories(startDate: startDate, endDate: endDate)
        
        let (stepCount, minutes, caloriesBurned) = try await (steps, activeMinutes, calories)
        
        return HealthKitActivity(
            date: date,
            steps: stepCount,
            activeMinutes: minutes,
            caloriesBurned: caloriesBurned,
            activityType: "HealthKit"
        )
    }
    
    func saveActivity(_ activity: Activity) async throws {
        let samples = createHealthKitSamples(for: activity)
        try await healthStore.save(samples)
    }
    
    private func fetchSteps(startDate: Date, endDate: Date) async throws -> Int {
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            throw HealthKitError.fetchingStepsFailed
        }
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        return Int(try await fetchQuantitySum(for: stepType, unit: .count(), predicate: predicate))
    }
    
    private func fetchActiveMinutes(startDate: Date, endDate: Date) async throws -> Int {
        guard let exerciseType = HKObjectType.quantityType(forIdentifier: .appleExerciseTime) else {
            throw HealthKitError.fetchingActiveMinutesFailed
        }
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        return Int(try await fetchQuantitySum(for: exerciseType, unit: .minute(), predicate: predicate))
    }

    private func fetchCalories(startDate: Date, endDate: Date) async throws -> Int {
        guard let calorieType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            throw HealthKitError.fetchingCaloriesFailed
        }
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        return Int(try await fetchQuantitySum(for: calorieType, unit: .kilocalorie(), predicate: predicate))
    }
    
    private func fetchQuantitySum(
        for quantityType: HKQuantityType,
        unit: HKUnit,
        predicate: NSPredicate
    ) async throws -> Double {
        try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: quantityType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                let sum = result?.sumQuantity()?.doubleValue(for: unit) ?? 0
                continuation.resume(returning: sum)
            }
            healthStore.execute(query)
        }
    }
    
    private func createHealthKitSamples(for activity: Activity) -> [HKSample] {
        var samples: [HKSample] = []
        
        if let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) {
            let stepQuantity = HKQuantity(unit: .count(), doubleValue: Double(activity.steps))
            let stepSample = HKQuantitySample(
                type: stepType,
                quantity: stepQuantity,
                start: activity.date,
                end: activity.date
            )
            samples.append(stepSample)
        }
        
        if let calorieType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) {
            let calorieQuantity = HKQuantity(unit: .kilocalorie(), doubleValue: Double(activity.caloriesBurned))
            let calorieSample = HKQuantitySample(
                type: calorieType,
                quantity: calorieQuantity,
                start: activity.date,
                end: activity.date
            )
            samples.append(calorieSample)
        }
        
        return samples
    }
}
