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
}
