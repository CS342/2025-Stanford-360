//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import FirebaseFirestore
import SwiftUI

extension Stanford360Standard {
    func storeHydrationLog(_ hydrationLog: HydrationLog) async {
        guard let logID = hydrationLog.id else {
            print("❌ Hydration Log ID is nil.")
            return
        }
        
        do {
            let docRef = try await configuration.userDocumentReference
            try await docRef.collection("hydrationLogs").document(logID).setData(from: hydrationLog)
        } catch {
            print("❌ Error writing hydration log to Firestore: \(error)")
        }
    }
    
    func fetchHydrationLogs() async -> [HydrationLog] {
        var hydrationLogs: [HydrationLog] = []
        
        do {
            let docRef = try await configuration.userDocumentReference
            let logsSnapshot = try await docRef.collection("hydrationLogs").getDocuments()
            
            hydrationLogs = try logsSnapshot.documents.compactMap { doc in
                try doc.data(as: HydrationLog.self)
            }
        } catch {
            print("❌ Error fetching hydration logs from Firestore: \(error)")
        }
        
        return hydrationLogs
    }
}
