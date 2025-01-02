import SwiftUI

struct GenerateWorkoutScreen: View {
    let userEmail: String
    @State private var workoutPlan: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading workout plan...")
                    .padding()
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else if !workoutPlan.isEmpty {
                ScrollView {
                    Text(workoutPlan)
                        .font(.body)
                        .padding()
                }
            } else {
                Text("Press the button below to generate your workout plan.")
                    .font(.subheadline)
                    .padding()
            }

            Button(action: fetchWorkoutPlan) {
                Text(isLoading ? "Loading..." : "Generate Workout Plan")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .navigationTitle("Generate Workout")
    }

    private func fetchWorkoutPlan() {
        isLoading = true
        errorMessage = nil

        guard let url = URL(string: "\(Secrets.apiUrl)/claude") else {
            errorMessage = "Invalid API URL."
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(Secrets.apiToken, forHTTPHeaderField: "x-api-key")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    errorMessage = "Error: \(error.localizedDescription)"
                    return
                }

                guard let data = data,
                      let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let workoutPlans = jsonResponse["workout_plan"] as? [[String: Any]],
                      let firstPlan = workoutPlans.first,
                      let planText = firstPlan["text"] as? String else {
                    errorMessage = "Failed to parse workout plan."
                    return
                }

                workoutPlan = planText
            }
        }.resume()
    }
}
