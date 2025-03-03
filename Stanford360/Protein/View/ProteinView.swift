//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

@_spi(TestingSupport) import SpeziAccount
import SwiftUI

struct ProteinView: View {
	@Environment(Stanford360Standard.self) private var standard
	@Environment(ProteinManager.self) private var proteinManager
	@Environment(Account.self) private var account: Account?
    
    @State private var showingAddProtein = false
    @State private var showingInfo = false
    @State private var isCardAnimating = false
    
	@Binding private var presentingAccount: Bool
	
	var body: some View {
		NavigationStack {
			ZStack {
				VStack(spacing: 20) {
					ProteinTimeFrameView()
					
					// Scrollable section for Daily Meals
					ScrollView {
						mealsCardView
					}
					.padding(20)
				}
				
				buttons
			}
			.navigationTitle("My Protein 🍗")
			.toolbar {
				if account != nil {
					AccountButton(isPresented: $presentingAccount)
				}
			}
			.sheet(isPresented: $showingAddProtein) {
				AddMealView()
			}
            .sheet(isPresented: $showingInfo) {
                MealRecsSheet()
            }
		}
		.task {
			await loadMeals()
		}
	}
    
    private var buttons: some View {
        ZStack {
            HStack {
                IconButton(
                    showingAddItem: $showingInfo,
                    imageName: "questionmark.circle.fill",
                    imageAccessibilityLabel: "Meal Recommendation Button",
                    color: .green
                )
                .padding(.trailing, 70)
                Spacer()
            }
            
            HStack {
                Spacer()
                IconButton(
                    showingAddItem: $showingAddProtein,
                    imageName: "plus.circle.fill",
                    imageAccessibilityLabel: "Add Protein Button",
                    color: .blue
                )
                .padding(.trailing, 10)
            }
        }
    }
    
	private var mealsCardView: some View {
        VStack(alignment: .leading, spacing: 20) {
            mealsHeaderView
            mealsList
                .opacity(isCardAnimating ? 1 : 0)
                .offset(y: isCardAnimating ? 0 : 50)
                .onAppear {
                    withAnimation(.spring(response: 0.8)) {
                        isCardAnimating = true
                    }
                }
        }
    }
    
	private var mealsHeaderView: some View {
        HStack {
            Text("Daily Meals")
                .font(.title2.bold())
            Spacer()
            Text("\(proteinManager.meals.count) Meals Logged")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(Color.blue.opacity(0.1))
                )
        }
    }
    
	private var mealsList: some View {
        VStack(spacing: 16) {
            if proteinManager.meals.isEmpty {
                Text("No meals logged yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(UIColor.secondarySystemGroupedBackground))
                    )
            } else {
                ForEach(proteinManager.meals) { meal in
                    mealRowView(
                        mealName: meal.name,
                        protein: "\(meal.proteinGrams)g",
                        time: meal.timestamp.formatted(date: .omitted, time: .shortened),
                        isCompleted: true
                    )
                    if meal.id != proteinManager.meals.last?.id {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
        .shadow(color: Color.black.opacity(0.05), radius: 10)
    }
	
	init(presentingAccount: Binding<Bool>) {
		self._presentingAccount = presentingAccount
	}
    
    func mealRowView(mealName: String, protein: String, time: String, isCompleted: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(mealName)
                    .font(.headline)
                Text(protein)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(time)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.trailing, 8)
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(isCompleted ? .blue : .gray.opacity(0.3))
                .symbolEffect(.bounce, value: isCompleted)
                .accessibilityLabel("circle")
        }
        .contentShape(Rectangle())
    }
    
    func loadMeals() async {
        proteinManager.meals = await standard.fetchMeals()
    }
}

#if DEBUG
#Preview {
	@Previewable @State var presentingAccount = false
    ProteinView(presentingAccount: $presentingAccount)
}
#endif
