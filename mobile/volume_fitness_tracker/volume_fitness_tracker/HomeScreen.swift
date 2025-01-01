import SwiftUI
import DGCharts

struct HomeScreen: View {
    let userEmail: String
    @State private var totalLifted: Int = 0
    @State private var yearlyProgressData: [YearlyProgress] = []
    @State private var exerciseData: [ExerciseData] = []
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    @State private var selectedExercise: String? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if isLoading {
                    ProgressView("Fetching your records...")
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Welcome, \(userEmail)!")
                            .font(.title2)
                            .bold()
                            .padding(.horizontal)

                        Text("Total Lifted: \(totalLifted) lbs")
                            .padding(.horizontal)

                        Divider()
                            .padding(.vertical)

                        Text("Yearly Progress")
                            .font(.headline)
                            .padding(.horizontal)

                        BarChartWrapper(totalLifted: Double(totalLifted), daysIntoYear: calculateDaysIntoYear())
                            .frame(height: 300)
                            .padding(.horizontal)

                        Text("Exercise Breakdown")
                            .font(.headline)
                            .padding(.horizontal)

                        if let selected = selectedExercise {
                            Text(selected)
                                .font(.headline)
                                .foregroundColor(.blue)
                                .padding(.horizontal)
                        } else {
                            Text("Select a section to see details")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        }

                        PieChartWrapper(data: exerciseData, selectedExercise: $selectedExercise)
                            .frame(height: 300)
                            .padding(.horizontal)
                    }
                }
            }
        }
        .onAppear {
            fetchData()
        }
    }

    private func fetchData() {
        APIClient.fetchData(for: userEmail) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let data):
                    totalLifted = Int(data["total_lifted"] as? Double ?? 0.0)

                    if let progressArray = data["yearly_progress"] as? [[String: Any]] {
                        yearlyProgressData = progressArray.compactMap { dict in
                            guard let month = dict["month"] as? String,
                                  let lifted = dict["lifted"] as? Int else { return nil }
                            return YearlyProgress(index: yearlyProgressData.count, month: month, lifted: lifted)
                        }
                    }

                    if let exerciseArray = data["exercise_data"] as? [String: [String: Double]] {
                        exerciseData = exerciseArray.map { key, value in
                            ExerciseData(exercise: key, value: Int(value["total_volume"] ?? 0.0))
                        }
                    }
                case .failure(let error):
                    errorMessage = "Failed to fetch data: \(error.localizedDescription)"
                }
            }
        }
    }

    private func calculateDaysIntoYear() -> Int {
        let currentDate = Date()
        let startOfYear = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: currentDate))!
        return Calendar.current.dateComponents([.day], from: startOfYear, to: currentDate).day ?? 0
    }
}
