import SwiftUI

struct InsertScreen: View {
    let userEmail: String
    @State private var date: Date = Date()
    @State private var exercises: [Exercise] = [Exercise(name: "", weight: 0, reps: 0)]
    @State private var totalVolume: Double?
    @State private var showConfirmation: Bool = false
    @State private var isDatePickerExpanded: Bool = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(.systemBackground)
                    .onTapGesture {
                        dismissKeyboard() // Dismiss the keyboard on tap
                    }

                VStack {
                    Text("Insert Workout for \(userEmail)")
                        .font(.title)
                        .padding()

                    Button(action: { isDatePickerExpanded.toggle() }) {
                        Text("Date: \(formatDate(date: date))")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    .padding()

                    if isDatePickerExpanded {
                        DatePicker("", selection: $date, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding()
                    }

                    List {
                        ForEach(exercises.indices, id: \.self) { index in
                            ExerciseRow(exercise: $exercises[index], onRemove: {
                                removeExercise(at: index)
                            })
                        }
                    }
                    .listStyle(InsetGroupedListStyle())

                    Button(action: addExercise) {
                        Text("Add Exercise")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }

                    Button(action: submitWorkout) {
                        Text("Submit")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }

                    if let totalVolume = totalVolume {
                        Text("Total Volume: \(totalVolume, specifier: "%.1f") lbs")
                            .font(.headline)
                            .padding()
                    }
                }
                .alert(isPresented: $showConfirmation) {
                    Alert(
                        title: Text("Workout Submitted"),
                        message: Text("Your workout has been recorded successfully. Total Volume: \(totalVolume?.description ?? "0.0") lbs."),
                        dismissButton: .default(Text("OK"), action: {
                            presentationMode.wrappedValue.dismiss()
                        })
                    )
                }
                .padding()
            }
        }
        .onDisappear {
            dismissKeyboard() // Dismiss keyboard when navigating away
        }
    }

    private func addExercise() {
        exercises.append(Exercise(name: "", weight: 0, reps: 0))
    }

    private func removeExercise(at index: Int) {
        exercises.remove(at: index)
    }

    private func submitWorkout() {
        guard !exercises.isEmpty else {
            print("Error: No exercises to submit")
            return
        }

        let apiUrl = "\(Secrets.apiUrl)/post"
        let apiKey = Secrets.apiToken
        let formattedDate = formatDate(date: date)

        let workoutData: [String: Any] = [
            "user": userEmail,
            "date": formattedDate,
            "exercises": exercises.map { $0.toDictionary() }
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: workoutData, options: .prettyPrinted) else {
            print("Error: Unable to serialize workout data")
            return
        }

        var request = URLRequest(url: URL(string: apiUrl)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.httpBody = jsonData

        print("Making API Request:")
        print("URL: \(apiUrl)")
        print("Headers: \(request.allHTTPHeaderFields ?? [:])")
        print("Body: \(String(data: jsonData, encoding: .utf8) ?? "Invalid JSON")")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Response Status Code: \(httpResponse.statusCode)")
            }

            if let data = data {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response Body: \(responseString)")
                } else {
                    print("Unable to decode response body.")
                }

                if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    DispatchQueue.main.async {
                        self.totalVolume = jsonResponse["total_volume"] as? Double
                        self.showConfirmation = true
                    }
                } else {
                    print("Error: Unable to parse JSON response.")
                }
            } else {
                print("Error: No data received.")
            }
        }.resume()
    }

    private func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct Exercise: Identifiable {
    let id = UUID()
    var name: String
    var weight: Double
    var reps: Int

    func toDictionary() -> [String: Any] {
        return ["name": name, "weight": weight, "reps": reps]
    }
}

struct ExerciseRow: View {
    @Binding var exercise: Exercise
    var onRemove: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                TextField("Exercise Name", text: $exercise.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disableAutocorrection(true)

                Button(action: onRemove) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .padding(.leading)
                }
            }

            HStack {
                TextField("Weight (lbs)", value: $exercise.weight, formatter: validNumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)

                TextField("Reps", value: $exercise.reps, formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
            }
        }
        .padding(.vertical, 5)
    }

    private func validNumberFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimum = 0
        return formatter
    }
}
