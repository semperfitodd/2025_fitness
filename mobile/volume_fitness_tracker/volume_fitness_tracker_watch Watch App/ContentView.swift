import SwiftUI

struct ContentView: View {
    @ObservedObject private var connectivityManager = WatchConnectivityManager.shared
    @State private var totalLifted: Int = 0
    @State private var errorMessage: String?
    @State private var isLoading: Bool = true

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
                    Text("\(String(format: "%.2f", calculateLiftedPercentage()))% of 15M")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .onAppear {
                retryFetchEmailAndData()
            }
            .tabItem {
                Label("Stats", systemImage: "chart.bar")
            }
        }
        .onAppear {
            logAppDetails()
        }
        .tabViewStyle(PageTabViewStyle())
    }

    private func fetchData() {
        isLoading = true
        print("Fetching data for email: \(connectivityManager.userEmail)")
        APIClient.fetchData(for: connectivityManager.userEmail) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let data):
                    print("API Response: \(data)")
                    totalLifted = Int(data["total_lifted"] as? Double ?? 0.0)
                case .failure(let error):
                    errorMessage = "Error fetching data: \(error.localizedDescription)"
                    print("Error Details: \(error)")
                }
            }
        }
    }

    private func retryFetchEmailAndData() {
        if connectivityManager.userEmail == "Guest" {
            print("Retrying to fetch email...")
            WatchConnectivityManager.shared.retryFetchingEmail() // Correctly call the method
        }
        fetchData()
    }

    private func calculateDaysIntoYear() -> Int {
        let currentDate = Date()
        let startOfYear = Calendar.current.date(from: Calendar.current.dateComponents([.year], from: currentDate))!
        let days = Calendar.current.dateComponents([.day], from: startOfYear, to: currentDate).day ?? 0
        return days + 1 // Add 1 to include the current day
    }

    private func calculateYearPercentage() -> Double {
        let days = calculateDaysIntoYear()
        return (Double(days) / 365.0) * 100.0
    }

    private func calculateLiftedPercentage() -> Double {
        return (Double(totalLifted) / 15000000.0) * 100.0
    }

    private func logAppDetails() {
        print("App Initialized")
        print("Email: \(connectivityManager.userEmail)")
        print("API URL: \(Secrets.apiUrl)")
        print("API Token: \(Secrets.apiToken)")
    }
}
