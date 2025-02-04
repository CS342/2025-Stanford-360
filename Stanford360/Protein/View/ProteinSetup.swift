//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProteinSetup: View {
    let onSave: (String, Double, String?) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var proteinGrams: Double = 0.0
    @State private var imageURL: String?

    var body: some View {
        Form {
            Section(header: Text("Add Meal")) {
                TextField("Meal Name", text: $name)
                TextField("Protein (g)", value: $proteinGrams, format: .number)
                    .keyboardType(.decimalPad)
            }

            Button("Save") {
                onSave(name, proteinGrams, imageURL)
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Add a Meal")
    }
}
