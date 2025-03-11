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
import Spezi

enum HealthKitError: Error {
//    case authorizationDenied
    case dateCalculationFailed
    case fetchingStepsFailed
    case fetchingActiveMinutesFailed
}

@MainActor
@Observable
class HealthKitManager: Module, EnvironmentAccessible {
    let healthStore: HKHealthStore
    var isHealthKitAuthorized = false
    private var healthKitObserver: Any?
    
    private let healthKitTypes: (read: Set<HKSampleType>, write: Set<HKSampleType>) = {
        guard
            let steps = HKObjectType.quantityType(forIdentifier: .stepCount),
            let exerciseTime = HKObjectType.quantityType(forIdentifier: .appleExerciseTime)
        else {
            // These types should always be available on iOS, but we'll handle the error case
            fatalError("Required HealthKit types are not available")
        }
        
        return (
            read: [steps, exerciseTime],
            write: [steps]
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
        
        let (stepCount, minutes) = try await (steps, activeMinutes)
        
        return HealthKitActivity(
            date: date,
            steps: stepCount,
            activeMinutes: minutes,
            activityType: "HealthKit"
        )
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
                if let error = error as? HKError, error.errorCode == HKError.Code.errorNoData.rawValue {
                    continuation.resume(returning: 0)
                    return
                } else if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                let sum = result?.sumQuantity()?.doubleValue(for: unit) ?? 0
                continuation.resume(returning: sum)
            }
            healthStore.execute(query)
        }
    }

    /// Converts HealthKit metrics into equivalent active minutes
    private func calculateActiveMinutes(steps: Int, exerciseMinutes: Int) -> Int {
        // Convert steps to minutes (assuming 100 steps per minute of activity)
        let stepsBasedMinutes = steps / 100
        
        // Take the maximum value to avoid double counting
        return max(exerciseMinutes, stepsBasedMinutes)
    }
    
    /// Fetches and converts HealthKit data into an Activity object
    func fetchAndConvertHealthKitData(for date: Date) async throws -> Activity {
        let healthKitActivity = try await readDailyActivity(for: date)
        
        // Calculate active minutes based on steps (100 steps ≈ 1 minute of activity)
        let convertedActiveMinutes = calculateActiveMinutes(
            steps: healthKitActivity.steps,
            exerciseMinutes: healthKitActivity.activeMinutes
        )
        
        return Activity(
            date: date,
            steps: healthKitActivity.steps,
            activeMinutes: convertedActiveMinutes,
            activityType: "Walking (HealthKit)"
        )
    }
}
