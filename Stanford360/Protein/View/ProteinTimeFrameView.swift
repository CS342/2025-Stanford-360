//
// This source file is part of the Stanford 360 based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2025 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Charts
import SwiftUI

struct ProteinTimeFrameView: View {
    let timeFrame: ProteinView.TimeFrame
    let proteinModel: ProteinIntakeModel
    
    var body: some View {
        switch timeFrame {
        case .today:
            todayView
        case .week:
            weeklyView
        case .month:
            monthlyView
        }
    }
    
    private var todayView: some View {
        VStack {
            DailyProgressView(currentValue: Int(proteinModel.totalProteinGrams), maxValue: 60)
                .frame(height: 200)
                .padding()
                
            if !proteinModel.meals.isEmpty {
                Text("Today's Meals")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                List {
                    ForEach(proteinModel.filterMeals(byDate: Date()), id: \.name) { meal in
                        MealCardView(meal: meal)
                    }
                }
                .listStyle(PlainListStyle())
            } else {
                List {
                    // Show a placeholder when no meals
                    Text("No meals logged today")
                        .foregroundColor(.gray)
                        .padding()
                }
                .listStyle(PlainListStyle())
            }
        }
    }
    
    private var weeklyView: some View {
        VStack(spacing: 20) {
            weeklyChartView()
            
            if !proteinModel.meals.isEmpty {
                ProteinBreakdownView(meals: getWeeklySummary())
                    .padding(.top, 20)
            } else {
                List {
                    // Show a placeholder when no meals
                    Text("No meals logged this week.")
                        .foregroundColor(.gray)
                        .padding()
                }
                .listStyle(PlainListStyle())
            }
        }
    }
    
    private var monthlyView: some View {
        VStack(spacing: 20) {
            monthlyChartView()
            
            if !proteinModel.meals.isEmpty {
                ProteinBreakdownView(meals: getMonthlyMeals())
            } else {
                List {
                    // Show a placeholder when no meals
                    Text("No meals logged this month.")
                        .foregroundColor(.gray)
                        .padding()
                }
                .listStyle(PlainListStyle())
            }
        }
    }
    
    // Weekly chart view
    private func weeklyChartView() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Protein Intake (Sunday - Saturday)")
                .font(.headline)
                .foregroundColor(.blue)
                .padding(.horizontal)
            
            Chart {
                ForEach(getDailyProteinData()) { data in
                    BarMark(
                        x: .value("Day", data.dayName),
                        y: .value("Protein", data.proteinGrams)
                    )
                    .foregroundStyle(Color.blue.gradient)
                }
                
                // Goal line
                RuleMark(y: .value("Goal", 60))
                    .foregroundStyle(.red)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    .annotation(position: .top, alignment: .leading) {
                        Text("Daily Goal")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
            }
            .chartYScale(domain: 0...100)
            .frame(height: 200)
            .padding()
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5)
        .padding(.horizontal)
    }
    
    // Monthly chart view
    private func monthlyChartView() -> some View {
        VStack(alignment: .leading) {
            Text("Monthly Protein Intake (Week-by-Week)")
                .font(.headline)
                .foregroundColor(.blue)
                .padding(.horizontal)
            
            Chart {
                ForEach(getWeeklyProteinData()) { data in
                    LineMark(
                        x: .value("Week", data.weekName),
                        y: .value("Protein", data.proteinGrams)
                    )
                    .symbol {
                        Circle().fill(.orange).frame(width: 8, height: 8)
                    }
                    .foregroundStyle(.orange)
                }
                
                // Goal line
                RuleMark(y: .value("Goal", 420))
                    .foregroundStyle(.red)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    .annotation(position: .top, alignment: .leading) {
                        Text("Weekly Goal")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
            }
            .chartYScale(domain: 0...500)
            .frame(height: 200)
            .padding()
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
        .shadow(color: Color.black.opacity(0.05), radius: 5)
        .padding(.horizontal)
    }
    
    // Helper functions to get data for charts and breakdowns
    func getWeeklySummary() -> [Meal] {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date())!
        return proteinModel.meals.filter { meal in
            meal.timestamp >= weekAgo && meal.timestamp <= Date()
        }
    }
    
    func getMonthlyMeals() -> [Meal] {
        let calendar = Calendar.current
        let monthAgo = calendar.date(byAdding: .month, value: -1, to: Date())!
        return proteinModel.meals.filter { meal in
            meal.timestamp >= monthAgo && meal.timestamp <= Date()
        }
    }
    
    // Data preparation for weekly chart
    func getDailyProteinData() -> [DailyProteinData] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekStartDate = calendar.date(byAdding: .day, value: -6, to: today)!
        
        // Get day names for the last week
        var dayNames: [String] = []
        var dates: [Date] = []
        for i in 0..<7 {
            let date = calendar.date(byAdding: .day, value: i, to: weekStartDate)!
            dates.append(date)
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"
            dayNames.append(formatter.string(from: date))
        }
        
        // Calculate protein intake for each day
        var result: [DailyProteinData] = []
        for (index, date) in dates.enumerated() {
            let dayMeals = proteinModel.meals.filter { meal in
                calendar.isDate(meal.timestamp, inSameDayAs: date)
            }
            let proteinAmount = dayMeals.reduce(0) { $0 + $1.proteinGrams }
            result.append(DailyProteinData(dayName: dayNames[index], proteinGrams: proteinAmount))
        }
        
        return result
    }
    
    // Data preparation for monthly chart
    func getWeeklyProteinData() -> [WeeklyProteinData] {
        let calendar = Calendar.current
        let today = Date()
        let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: today)!
        
        var weeklyData: [WeeklyProteinData] = []
        var currentWeekStart = calendar.date(byAdding: .day, value: -6, to: today)!
        
        // Generate 4 weeks of data
        for i in 0..<4 {
            let weekStart = calendar.date(byAdding: .weekOfYear, value: -i, to: currentWeekStart)!
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!
            
            let weekMeals = proteinModel.meals.filter { meal in
                meal.timestamp >= weekStart && meal.timestamp <= weekEnd
            }
            
            let totalProtein = weekMeals.reduce(0) { $0 + $1.proteinGrams }
            let weekName = "Week \(4-i)"
            
            weeklyData.insert(WeeklyProteinData(weekName: weekName, proteinGrams: totalProtein), at: 0)
        }
        
        return weeklyData
    }
}

// Needed view components
struct MealCardView: View {
    let meal: Meal
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(meal.name)
                    .font(.headline)
                Text("\(meal.proteinGrams, specifier: "%.1f")g protein")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(meal.timestamp, style: .time)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

struct ProteinBreakdownView: View {
    let meals: [Meal]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Protein Breakdown")
                .font(.headline)
                .padding(.horizontal)
            
            if meals.isEmpty {
                Text("No meals to analyze")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                VStack(spacing: 12) {
                    HStack {
                        Text("Total Protein:")
                            .font(.subheadline)
                        Spacer()
                        Text("\(totalProtein, specifier: "%.1f") g")
                            .font(.subheadline)
                            .fontWeight(.bold)
                    }
                    
                    HStack {
                        Text("Average Per Day:")
                            .font(.subheadline)
                        Spacer()
                        Text("\(averagePerDay, specifier: "%.1f") g")
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Text("Total Meals:")
                            .font(.subheadline)
                        Spacer()
                        Text("\(meals.count)")
                            .font(.subheadline)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.secondarySystemGroupedBackground))
                )
                .padding(.horizontal)
            }
        }
    }
    
    private var totalProtein: Double {
        meals.reduce(0) { $0 + $1.proteinGrams }
    }
    
    private var averagePerDay: Double {
        let calendar = Calendar.current
        let dates = meals.map { meal in
            calendar.startOfDay(for: meal.timestamp)
        }
        let uniqueDates = Set(dates)
        guard !uniqueDates.isEmpty else { return 0 }
        return totalProtein / Double(uniqueDates.count)
    }
}

// Data models for charts
struct DailyProteinData: Identifiable {
    let id = UUID()
    let dayName: String
    let proteinGrams: Double
}

struct WeeklyProteinData: Identifiable {
    let id = UUID()
    let weekName: String
    let proteinGrams: Double
}

// Extension for TimeFrame enum
extension ProteinView {
    enum TimeFrame {
        case today
        case week
        case month
    }
}

// Preview
#Preview {
    let proteinModel = ProteinIntakeModel(
        userID: "user1",
        date: Date(),
        meals: [
            Meal(name: "Breakfast", proteinGrams: 25, timestamp: Date()),
            Meal(name: "Lunch", proteinGrams: 35, timestamp: Date()),
            Meal(name: "Dinner", proteinGrams: 40, timestamp: Date().addingTimeInterval(-86400))
        ]
    )
    
    return ProteinTimeFrameView(
        timeFrame: .week,
        proteinModel: proteinModel
    )
}
