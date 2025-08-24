import SwiftUI

struct ContentView: View {
    @State private var totalLifted: Int = 0
    @State private var exerciseData: [ExerciseData] = []
    @State private var errorMessage: String?
    @State private var isLoading: Bool = true
    @State private var currentTab = 0

    private let userEmail = "todd@bernsonfamily.com"

    var body: some View {
        TabView(selection: $currentTab) {
            // Progress Overview
            progressOverviewView
                .tag(0)
            
            // Top Exercises
            topExercisesView
                .tag(1)
            
            // Daily Stats
            dailyStatsView
                .tag(2)
        }
        .tabViewStyle(PageTabViewStyle())
        .onAppear {
            print("⌚ Watch App: ContentView appeared")
            fetchData()
        }
    }
    
    // MARK: - Progress Overview Tab
    private var progressOverviewView: some View {
        VStack(spacing: 8) {
            if isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
            } else if let errorMessage = errorMessage {
                VStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.red)
                    Text(errorMessage)
                        .font(.caption2)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
            } else {
                VStack(spacing: 8) {
                    // Progress Ring
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 6)
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .trim(from: 0, to: progressPercentage / 100)
                            .stroke(progressColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 1.0), value: progressPercentage)
                        
                        VStack(spacing: 2) {
                            Text("\(Int(progressPercentage))%")
                                .font(.system(size: 16, weight: .bold))
                            Text("Goal")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Total Lifted
                    VStack(spacing: 2) {
                        Text(formatTotalLifted())
                            .font(.system(size: 18, weight: .bold))
                        Text("Total Lifted")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
    }
    
    // MARK: - Top Exercises Tab
    private var topExercisesView: some View {
        VStack(spacing: 8) {
            Text("Top Exercises")
                .font(.system(size: 14, weight: .semibold))
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.caption2)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            } else {
                ScrollView {
                    VStack(spacing: 6) {
                        ForEach(Array(exerciseData.prefix(5).enumerated()), id: \.element.id) { index, exercise in
                            HStack {
                                Text("\(index + 1)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.blue)
                                    .frame(width: 20)
                                
                                Text(exercise.exercise.capitalized)
                                    .font(.system(size: 12))
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                Text(formatExerciseValue(exercise.value))
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    // MARK: - Daily Stats Tab
    private var dailyStatsView: some View {
        VStack(spacing: 8) {
            Text("Daily Progress")
                .font(.system(size: 14, weight: .semibold))
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .font(.caption2)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            } else {
                VStack(spacing: 12) {
                    // Days Progress
                    VStack(spacing: 4) {
                        Text("\(daysIntoYear)")
                            .font(.system(size: 20, weight: .bold))
                        Text("Days")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                    
                    // Daily Target
                    VStack(spacing: 4) {
                        Text(formatDailyTarget())
                            .font(.system(size: 16, weight: .semibold))
                        Text("Daily Target")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                    
                    // Current Average
                    VStack(spacing: 4) {
                        Text(formatCurrentAverage())
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(currentAverageColor)
                        Text("Your Average")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
    }
    
    // MARK: - Computed Properties
    private var progressPercentage: Double {
        guard totalLifted > 0 else { return 0 }
        return (Double(totalLifted) / Double(WatchConstants.yearlyGoalLbs)) * 100.0
    }
    
    private var progressColor: Color {
        if progressPercentage >= 80 {
            return .green
        } else if progressPercentage >= 60 {
            return .orange
        } else {
            return .blue
        }
    }
    
    private var daysIntoYear: Int {
        let currentDate = Date()
        let startOfYear = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: currentDate))!
        return Calendar.current.dateComponents([.day], from: startOfYear, to: currentDate).day ?? 0 + 1
    }
    
    private var dailyTarget: Double {
        return Double(WatchConstants.yearlyGoalLbs) / Double(WatchConstants.daysInYear)
    }
    
    private var currentDailyAverage: Double {
        guard daysIntoYear > 0 else { return 0 }
        return Double(totalLifted) / Double(daysIntoYear)
    }
    
    private var currentAverageColor: Color {
        if currentDailyAverage >= dailyTarget {
            return .green
        } else if currentDailyAverage >= dailyTarget * 0.8 {
            return .orange
        } else {
            return .red
        }
    }
    
    // MARK: - Helper Methods
    private func formatTotalLifted() -> String {
        if totalLifted >= 1_000_000 {
            return String(format: "%.1fM", Double(totalLifted) / 1_000_000)
        } else if totalLifted >= 1_000 {
            return String(format: "%.1fK", Double(totalLifted) / 1_000)
        } else {
            return "\(totalLifted)"
        }
    }
    
    private func formatExerciseValue(_ value: Int) -> String {
        if value >= 1_000_000 {
            return String(format: "%.1fM", Double(value) / 1_000_000)
        } else if value >= 1_000 {
            return String(format: "%.1fK", Double(value) / 1_000)
        } else {
            return "\(value)"
        }
    }
    
    private func formatDailyTarget() -> String {
        if dailyTarget >= 1_000_000 {
            return String(format: "%.1fM", dailyTarget / 1_000_000)
        } else if dailyTarget >= 1_000 {
            return String(format: "%.1fK", dailyTarget / 1_000)
        } else {
            return String(format: "%.0f", dailyTarget)
        }
    }
    
    private func formatCurrentAverage() -> String {
        if currentDailyAverage >= 1_000_000 {
            return String(format: "%.1fM", currentDailyAverage / 1_000_000)
        } else if currentDailyAverage >= 1_000 {
            return String(format: "%.1fK", currentDailyAverage / 1_000)
        } else {
            return String(format: "%.0f", currentDailyAverage)
        }
    }
    
    // MARK: - Data Fetching
    private func fetchData() {
        print("⌚ Watch App: Starting fetchData()")
        isLoading = true
        errorMessage = nil
        
        WatchAPIClient.fetchData(for: userEmail) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let response):
                    totalLifted = Int(response.totalLifted)
                    exerciseData = response.exerciseData.map { (exerciseName, detail) in
                        ExerciseData(exercise: exerciseName, value: Int(detail.totalVolume))
                    }.sorted { $0.value > $1.value }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
