import SwiftUI

struct ContentView: View {
    @State private var totalLifted: Int = 0
    @State private var errorMessage: String?
    @State private var isLoading: Bool = true

    private let userEmail = "todd@bernsonfamily.com"

    var body: some View {
        TabView {
            // First Screen: Year Completed
            VStack {
                Text("Year Completed")
                    .font(.title)
                    .padding(.bottom, 4)
                Divider()
                    .background(Color.gray)
                    .padding(.horizontal)
                Text("\(calculateDaysIntoYear()) days")
                    .font(.headline)
                    .padding(.top, 4)
                Text("\(String(format: "%.2f", calculateYearPercentage()))%")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .tabItem {
                Label("Progress", systemImage: "calendar")
            }

            // Second Screen: Lifted Data
            VStack {
                if isLoading {
                    ProgressView("Loading...")
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                } else {
                    Text("# Lifted")
                        .font(.title)
                        .padding(.bottom, 4)
                    Divider()
                        .background(Color.gray)
                        .padding(.horizontal)
                    Text("\(totalLifted) lbs")
                        .font(.headline)
                        .padding(.top, 4)
                    Text("\(String(format: "%.2f", calculateLiftedPercentage()))% of 25M")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .onAppear {
                fetchData()
            }
            .tabItem {
                Label("Stats", systemImage: "chart.bar")
            }
        }
        .tabViewStyle(PageTabViewStyle())
    }

    private func fetchData() {
        isLoading = true
        APIClient.fetchData(for: userEmail) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let data):
                    totalLifted = Int(data["total_lifted"] as? Double ?? 0.0)
                case .failure(let error):
                    errorMessage = "Error fetching data: \(error.localizedDescription)"
                }
            }
        }
    }

    private func calculateDaysIntoYear() -> Int {
        let currentDate = Date()
        let startOfYear = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: currentDate))!
        return Calendar.current.dateComponents([.day], from: startOfYear, to: currentDate).day ?? 0 + 1
    }

    private func calculateYearPercentage() -> Double {
        let days = calculateDaysIntoYear()
        return (Double(days) / 365.0) * 100.0
    }

    private func calculateLiftedPercentage() -> Double {
        return (Double(totalLifted) / 25_000_000.0) * 100.0
    }
}
