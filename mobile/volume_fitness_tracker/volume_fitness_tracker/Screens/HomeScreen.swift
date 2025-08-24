import SwiftUI
import DGCharts

struct HomeScreen: View {
    let userEmail: String
    @StateObject private var viewModel: HomeViewModel
    
    init(userEmail: String) {
        self.userEmail = userEmail
        self._viewModel = StateObject(wrappedValue: HomeViewModel(userEmail: userEmail))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if viewModel.isLoading {
                        LoadingView("Fetching your records...")
                    } else if let errorMessage = viewModel.errorMessage {
                        ErrorView(
                            message: errorMessage,
                            onRetry: {
                                Task {
                                    await viewModel.fetchData()
                                }
                            }
                        )
                    } else {
                        contentView
                    }
                }
                .padding()
            }
            .navigationTitle("Fitness Tracker")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.fetchData()
            }
        }
        .task {
            await viewModel.fetchData()
        }
    }
    
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Welcome Section
            welcomeSection
            
            // Progress Section
            progressSection
            
            // Charts Section
            chartsSection
        }
    }
    
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome, \(userEmail)!")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Total Lifted: \(viewModel.totalLifted.formatted()) lbs")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
    
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Yearly Progress")
                .font(.headline)
                .fontWeight(.semibold)
            
            let progressPercentage = viewModel.calculateProgressPercentage()
            let daysIntoYear = viewModel.calculateDaysIntoYear()
            let daysRemaining = Constants.daysInYear - daysIntoYear
            let dailyTarget = Double(viewModel.calculateYearlyGoal()) / Double(Constants.daysInYear)
            let currentDailyAverage = Double(viewModel.totalLifted) / Double(daysIntoYear)
            let projectedTotal = currentDailyAverage * Double(Constants.daysInYear)
            
            VStack(spacing: 16) {
                // Main Progress Card
                VStack(spacing: 12) {
                    HStack {
                        Text("Goal: \(viewModel.calculateYearlyGoal().formatted()) lbs")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(progressPercentage, specifier: "%.1f")%")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                    
                    ProgressView(value: progressPercentage, total: 100)
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .scaleEffect(y: 2)
                    
                    Text("Day \(daysIntoYear) of \(Constants.daysInYear)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Cool Progress Breakdown
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "target")
                            .foregroundColor(.blue)
                            .font(.title2)
                        
                        Text("Progress Breakdown")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                    }
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        // Daily Target
                        ProgressCard(
                            title: "Daily Target",
                            value: dailyTarget,
                            unit: "lbs",
                            color: .blue,
                            icon: "calendar.badge.clock"
                        )
                        
                        // Current Average
                        ProgressCard(
                            title: "Your Average",
                            value: currentDailyAverage,
                            unit: "lbs",
                            color: currentDailyAverage >= dailyTarget ? .green : .orange,
                            icon: "chart.line.uptrend.xyaxis"
                        )
                        
                        // Days Remaining
                        ProgressCard(
                            title: "Days Left",
                            value: Double(daysRemaining),
                            unit: "days",
                            color: .purple,
                            icon: "clock.arrow.circlepath"
                        )
                        
                        // Projected Total
                        ProgressCard(
                            title: "Projected",
                            value: projectedTotal,
                            unit: "lbs",
                            color: projectedTotal >= Double(viewModel.calculateYearlyGoal()) ? .green : .red,
                            icon: "chart.bar.fill"
                        )
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
        }
    }
    
    private var chartsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Exercise Breakdown
            VStack(alignment: .leading, spacing: 12) {
                Text("Exercise Breakdown")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                if let selectedExercise = viewModel.selectedExercise {
                    Text(selectedExercise)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                } else {
                    Text("Select a section to see details")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                PieChartWrapper(
                    data: viewModel.exerciseData,
                    selectedExercise: Binding(
                        get: { viewModel.selectedExercise },
                        set: { viewModel.selectExercise($0) }
                    )
                )
                .frame(height: 300)
            }
        }
    }
}

#Preview {
    HomeScreen(userEmail: "test@example.com")
}
