// import XCTest
// @testable import Stanford360
// import HealthKit
//
// @MainActor
// final class HealthKitManagerTests: XCTestCase {
//    var healthKitManager: HealthKitManager!
//    var mockHealthStore: HKHealthStoreMock!
//
//    override func setUp() async throws {
//        try await super.setUp()
//        mockHealthStore = HKHealthStoreMock()
//        healthKitManager = HealthKitManager(healthStore: mockHealthStore)
//    }
//
//    func testRequestAuthorization() async throws {
//        XCTAssertFalse(healthKitManager.isHealthKitAuthorized)
//
//        try await healthKitManager.requestAuthorization()
//
//        XCTAssertTrue(healthKitManager.isHealthKitAuthorized)
//        XCTAssertTrue(mockHealthStore.requestAuthorizationCalled)
//    }
//
//    func testReadDailyActivity() async throws {
//        let expectedActivity = HealthKitActivity(date: Date(), steps: 5000, activeMinutes: 30, caloriesBurned: 200, activityType: "HealthKit")
//        mockHealthStore.stepCount = 5000
//        mockHealthStore.activeMinutes = 30
//        mockHealthStore.caloriesBurned = 200
//
//        let activity = try await healthKitManager.readDailyActivity(for: Date())
//
//        XCTAssertEqual(activity.steps, expectedActivity.steps)
//        XCTAssertEqual(activity.activeMinutes, expectedActivity.activeMinutes)
//        XCTAssertEqual(activity.caloriesBurned, expectedActivity.caloriesBurned)
//    }
//
//    func testSaveActivity() async throws {
//        let activity = Activity(date: Date(), steps: 8000, activeMinutes: 60, caloriesBurned: 400, activityType: "Manual")
//
//        try await healthKitManager.saveActivity(activity)
//
//        XCTAssertTrue(mockHealthStore.saveCalled)
//    }
// }
//
// class HKHealthStoreMock: HKHealthStore {
//    var requestAuthorizationCalled = false
//    var saveCalled = false
//    var stepCount = 0
//    var activeMinutes = 0
//    var caloriesBurned = 0
//
//    override func requestAuthorization(toShare typesToShare: Set<HKSampleType>?, read typesToRead: Set<HKObjectType>?, completion: @escaping (Bool, Error?) -> Void) {
//        requestAuthorizationCalled = true
//        completion(true, nil)
//    }
//
//    override func execute(_ query: HKQuery) {
//        if let statisticsQuery = query as? HKStatisticsCollectionQuery {
//            let quantityType = statisticsQuery.quantityType
//            let quantity = HKQuantity(unit: quantityType.unit, doubleValue: Double(self.value(for: quantityType)))
//            let statistics = HKStatistics(quantityType: quantityType, quantitySamplePredicate: nil, options: .cumulativeSum, startDate: Date(), endDate: Date(), sum: quantity)
//            let statisticsCollection = HKStatisticsCollection(statistics: [statistics], statisticsOptions: statisticsQuery.options)
//            statisticsQuery.initialResultsHandler?(statisticsCollection, nil, nil)
//        }
//    }
//
//    override func save(_ samples: [HKSample], withCompletion completion: @escaping (Bool, Error?) -> Void) {
//        saveCalled = true
//        completion(true, nil)
//    }
//
//    private func value(for quantityType: HKQuantityType) -> Double {
//        switch quantityType {
//        case HKObjectType.quantityType(forIdentifier: .stepCount)!:
//            return Double(stepCount)
//        case HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!:
//            return Double(activeMinutes)
//        case HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!:
//            return Double(caloriesBurned)
//        default:
//            return 0
//        }
//    }
// }
