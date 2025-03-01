//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//
import BackgroundTasks
import class FirebaseFirestore.FirestoreSettings
import class FirebaseFirestore.MemoryCacheSettings
import Spezi
import SpeziAccount
import SpeziFirebaseAccount
import SpeziFirebaseAccountStorage
import SpeziFirebaseStorage
import SpeziFirestore
import SpeziHealthKit
import SpeziNotifications
import SpeziOnboarding
import SpeziScheduler
import SwiftUI
import UserNotifications


class Stanford360Delegate: SpeziAppDelegate {
	//    let activityReminderTaskId = "com.stanford360.activityReminder"
	//    let sharedActivityManager = ActivityManager()
	
	override var configuration: Configuration {
		Configuration(standard: Stanford360Standard()) {
			if !FeatureFlags.disableFirebase {
				AccountConfiguration(
					service: FirebaseAccountService(providers: [.emailAndPassword, .signInWithApple], emulatorSettings: accountEmulator),
					storageProvider: FirestoreAccountStorage(storeIn: FirebaseConfiguration.userCollection),
					configuration: [
						.requires(\.userId),
						.requires(\.name),
						
						// additional values stored using the `FirestoreAccountStorage` within our Standard implementation
						.collects(\.genderIdentity),
						.collects(\.dateOfBirth)
					]
				)
				
				firestore
				if FeatureFlags.useFirebaseEmulator {
					FirebaseStorageConfiguration(emulatorSettings: (host: "localhost", port: 9199))
				} else {
					FirebaseStorageConfiguration()
				}
			}
			
			if HKHealthStore.isHealthDataAvailable() {
				healthKit
			}
			
			Stanford360Scheduler()
			Scheduler()
			OnboardingDataSource()
			Notifications()
			PatientManager()
			ActivityManager()
			HydrationManager()
			ProteinManager()
			HealthKitManager()
		}
	}
	
	private var accountEmulator: (host: String, port: Int)? {
		if FeatureFlags.useFirebaseEmulator {
			(host: "localhost", port: 9099)
		} else {
			nil
		}
	}
	
	private var firestore: Firestore {
		let settings = FirestoreSettings()
		if FeatureFlags.useFirebaseEmulator {
			settings.host = "localhost:8080"
			settings.cacheSettings = MemoryCacheSettings()
			settings.isSSLEnabled = false
		}
		
		return Firestore(
			settings: settings
		)
	}
	
	
	private var healthKit: HealthKit {
		HealthKit {
			CollectSample(
				HKQuantityType(.stepCount),
				deliverySetting: .anchorQuery(.automatic)
			)
			CollectSample(
				HKQuantityType(.distanceWalkingRunning),
				deliverySetting: .anchorQuery(.automatic)
			)
			CollectSample(
				HKQuantityType(.activeEnergyBurned),
				deliverySetting: .anchorQuery(.automatic)
			)
		}
	}
	
	//    override func application(
	//        _ application: UIApplication,
	//        willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = [:]
	//    ) -> Bool {
	//        registerBackgroundTask()
	//        scheduleBackgroundActivityReminder()
	//        if !UserDefaults.standard.bool(forKey: "hasAskedForNotificationPermission") {
	//            requestNotificationPermission()
	//        }
	//        return true
	//    }
	//
	//    /// Registers the background task
	//    private func registerBackgroundTask() {
	//        BGTaskScheduler.shared.register(
	//            forTaskWithIdentifier: activityReminderTaskId,
	//            using: nil
	//        ) { task in
	//            if let task = task as? BGAppRefreshTask {
	//                self.handleBackgroundActivityReminder(
	//                    task: task,
	//                    activityManager: self.sharedActivityManager
	//                )
	//            }
	//        }
	//    }
	//
	//    /// Schedules the background task to start at 8 AM and repeat every 5 hours
	//    func scheduleBackgroundActivityReminder() {
	//        let request = BGAppRefreshTaskRequest(identifier: activityReminderTaskId)
	//
	//        guard let baseDate = Calendar.current.date(
	//            bySettingHour: 8,
	//            minute: 0,
	//            second: 0,
	//            of: Date()
	//        ) else {
	//            print("Failed to compute base date for scheduling.")
	//            return
	//        }
	//        let nextRun = baseDate.addingTimeInterval(5 * 60 * 60) // 8 AM first, then run every 5 hours
	//        request.earliestBeginDate = nextRun
	//
	//        do {
	//            try BGTaskScheduler.shared.submit(request)
	//            if let earliestDate = request.earliestBeginDate {
	//                print("Scheduled background activity reminder at \(earliestDate)")
	//            } else {
	//                print("Failed to retrieve earliest begin date.")
	//            }
	//        } catch {
	//            print("Failed to schedule activity reminder: \(error.localizedDescription)")
	//        }
	//    }
	//
	//    /// Handles the background task execution
	//    func handleBackgroundActivityReminder(task: BGAppRefreshTask, activityManager: ActivityManager) {
	//        activityManager.sendActivityReminder()
	//        task.setTaskCompleted(success: true)
	//        scheduleBackgroundActivityReminder() // Reschedule for continuous monitoring
	//    }
	//
	//
	//    /// Requests notification permissions
	//    private func requestNotificationPermission() {
	//        let center = UNUserNotificationCenter.current()
	//        center.getNotificationSettings { settings in
	//            guard settings.authorizationStatus == .notDetermined else {
	//                return
	//            }
	//
	//            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
	//                if granted {
	//                    print("Notification permission granted!")
	//                    UserDefaults.standard.set(true, forKey: "hasAskedForNotificationPermission")
	//                } else if let error = error {
	//                    print("Failed to request notification permission: \(error)")
	//                }
	//            }
	//        }
	//    }
}
