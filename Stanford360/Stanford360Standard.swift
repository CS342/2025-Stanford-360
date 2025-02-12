//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

@preconcurrency import FirebaseFirestore
@preconcurrency import FirebaseStorage
import HealthKitOnFHIR
import OSLog
@preconcurrency import PDFKit.PDFDocument
import Spezi
import SpeziAccount
import SpeziFirebaseAccount
import SpeziFirestore
import SpeziHealthKit
import SpeziOnboarding
import SpeziQuestionnaire
import SwiftUI


actor Stanford360Standard: Standard,
                                   EnvironmentAccessible,
                                   HealthKitConstraint,
                                   ConsentConstraint,
                                   AccountNotifyConstraint {
    @Application(\.logger) private var logger

    @Dependency(FirebaseConfiguration.self) private var configuration

    init() {}


    func add(sample: HKSample) async {
        if FeatureFlags.disableFirebase {
            logger.debug("Received new HealthKit sample: \(sample)")
            return
        }
        
        do {
            try await healthKitDocument(id: sample.id)
                .setData(from: sample.resource)
        } catch {
            logger.error("Could not store HealthKit sample: \(error)")
        }
    }
    
    func remove(sample: HKDeletedObject) async {
        if FeatureFlags.disableFirebase {
            logger.debug("Received new removed healthkit sample with id \(sample.uuid)")
            return
        }
        
        do {
            try await healthKitDocument(id: sample.uuid).delete()
        } catch {
            logger.error("Could not remove HealthKit sample: \(error)")
        }
    }

    // periphery:ignore:parameters isolation
    func add(response: ModelsR4.QuestionnaireResponse, isolation: isolated (any Actor)? = #isolation) async {
        let id = response.identifier?.value?.value?.string ?? UUID().uuidString
        
        if FeatureFlags.disableFirebase {
            let jsonRepresentation = (try? String(data: JSONEncoder().encode(response), encoding: .utf8)) ?? ""
            await logger.debug("Received questionnaire response: \(jsonRepresentation)")
            return
        }
        
        do {
            try await configuration.userDocumentReference
                .collection("QuestionnaireResponse") // Add all HealthKit sources in a /QuestionnaireResponse collection.
                .document(id) // Set the document identifier to the id of the response.
                .setData(from: response)
        } catch {
            await logger.error("Could not store questionnaire response: \(error)")
        }
    }
    
    
    private func healthKitDocument(id uuid: UUID) async throws -> DocumentReference {
        try await configuration.userDocumentReference
            .collection("HealthKit") // Add all HealthKit sources in a /HealthKit collection.
            .document(uuid.uuidString) // Set the document identifier to the UUID of the document.
    }

    func respondToEvent(_ event: AccountNotifications.Event) async {
        if case let .deletingAccount(accountId) = event {
            do {
                try await configuration.userDocumentReference(for: accountId).delete()
            } catch {
                logger.error("Could not delete user document: \(error)")
            }
        }
    }
    
    /// Stores the given consent form in the user's document directory with a unique timestamped filename.
    ///
    /// - Parameter consent: The consent form's data to be stored as a `PDFDocument`.
    @MainActor
    func store(consent: ConsentDocumentExport) async throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmmss"
        let dateString = formatter.string(from: Date())

        guard !FeatureFlags.disableFirebase else {
            guard let basePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                await logger.error("Could not create path for writing consent form to user document directory.")
                return
            }
            
            let filePath = basePath.appending(path: "consentForm_\(dateString).pdf")
            await consent.pdf.write(to: filePath)
            
            return
        }
        
        do {
            guard let consentData = await consent.pdf.dataRepresentation() else {
                await logger.error("Could not store consent form.")
                return
            }

            let metadata = StorageMetadata()
            metadata.contentType = "application/pdf"
            _ = try await configuration.userBucketReference
                .child("consent/\(dateString).pdf")
                .putDataAsync(consentData, metadata: metadata) { @Sendable _ in }
        } catch {
            await logger.error("Could not store consent form: \(error)")
        }
    }
    
    /// Store hydration document under hydrationLog
    private func hydrationDocument(date: Date) async throws -> DocumentReference {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        return try await configuration.userDocumentReference
            .collection("hydrationLogs")
            .document(dateString)
    }
    
    /// Add or Update Hydration Log
    func addOrUpdateHydrationLog(hydrationLog: HydrationLog) async {
        do {
            let currentDate = Date()

            let hydrationDocRef = try await hydrationDocument(date: currentDate)

            // Update or create the document
            try await hydrationDocRef.setData(from: hydrationLog, merge: true)

        } catch {
            print("❌ Error updating hydration log: \(error)")
        }
    }
    
    /// Fetches the hydration log for the current date
    @MainActor
    func fetchHydrationLog() async throws -> HydrationLog? {
        do {
            let currentDate = Date()
            let hydrationDocRef = try await hydrationDocument(date: currentDate)
            print("✅ Current's date: \(currentDate)")

            let document = try await hydrationDocRef.getDocument()

            // Check if document exists
            if document.exists, let data = document.data() {
                // Extract each field safely
                let amountOz = data["amountOz"] as? Double ?? 0.0
                let streak = data["streak"] as? Int ?? 0
                let lastTriggeredMilestone = data["lastTriggeredMilestone"] as? Double ?? 0.0
                let lastHydrationDate = (data["lastHydrationDate"] as? Timestamp)?.dateValue() ?? Date()
                let date = (data["date"] as? Timestamp)?.dateValue() ?? Date()
                let isStreakUpdated = data["isStreakUpdated"] as? Bool ?? false

                return HydrationLog(
                    date: date,
                    amountOz: amountOz,
                    streak: streak,
                    lastTriggeredMilestone: lastTriggeredMilestone,
                    lastHydrationDate: lastHydrationDate,
                    isStreakUpdated: isStreakUpdated,
                    id: document.documentID
                )
            } else {
                print("⚠️ No hydration log found for today.")
                return nil
            }
        } catch {
            print("❌ Error fetching hydration log: \(error)")
            return nil
        }
    }
    
    @MainActor
    func fetchYesterdayStreak() async -> Int {
        do {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today
            let hydrationDocRef = try await hydrationDocument(date: yesterday)

            let document = try await hydrationDocRef.getDocument()

            if document.exists, let data = document.data() {
                let yesterdayStreak = data["streak"] as? Int ?? 0
                let yesterdayIntake = data["amountOz"] as? Double ?? 0.0

                return yesterdayIntake >= 60 ? yesterdayStreak : 0
            } else {
                return 0
            }
        } catch {
            return 0
        }
    }
}
