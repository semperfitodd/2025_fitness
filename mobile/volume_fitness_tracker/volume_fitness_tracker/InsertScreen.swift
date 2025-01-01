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
                    ExerciseRow(exercise: $exercises[index])
                }
                .onDelete(perform: removeExercise)
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
                message: Text("Your workout has been recorded successfully. Total Volume: \(totalVolume ?? 0, specifier: "%.1f") lbs."),
                dismissButton: .default(Text("OK"), action: {
                    // Navigate back to the home screen
                    presentationMode.wrappedValue.dismiss()
                })
            )
        }
        .padding()
    }

    private func addExercise() {
        exercises.append(Exercise(name: "", weight: 0, reps: 0))
    }

    private func removeExercise(at offsets: IndexSet) {
        exercises.remove(atOffsets: offsets)
    }

    private func submitWorkout() {
        let apiUrl = Secrets.apiUrl
        let apiKey = Secrets.apiToken

        let formattedDate = formatDate(date: date)

        let workoutData: [String: Any] = [
            "user": userEmail,
            "date": formattedDate,
            "exercises": exercises.map { $0.toDictionary() }
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: workoutData) else {
            print("Error: Unable to serialize workout data")
            return
        }

        var request = URLRequest(url: URL(string: apiUrl)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                DispatchQueue.main.async {
                    self.totalVolume = jsonResponse["total_volume"] as? Double
                    self.showConfirmation = true
                }
            }
        }.resume()
    }

    private func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
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

    var body: some View {
        VStack(alignment: .leading) {
            TextField("Exercise Name", text: $exercise.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disableAutocorrection(true)

            HStack {
                TextField("Weight (lbs)", value: $exercise.weight, formatter: validNumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .onChange(of: exercise.weight) { oldValue, newValue in
                        if newValue < 0 || newValue.isNaN || newValue.isInfinite {
                            exercise.weight = max(0, oldValue ?? 0) // Reset to the last valid value
                        }
                    }

                TextField("Reps", value: $exercise.reps, formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .onChange(of: exercise.reps) { oldValue, newValue in
                        if newValue < 0 {
                            exercise.reps = max(0, oldValue ?? 0) // Reset to the last valid value
                        }
                    }
            }
        }
        .padding(.vertical, 5)
    }

    private func validNumberFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimum = 0 // Ensure no negative numbers
        return formatter
    }
}

extension UITextField {
    override open func layoutSubviews() {
        super.layoutSubviews()
        inputAssistantItem.leadingBarButtonGroups = []
        inputAssistantItem.trailingBarButtonGroups = []
    }
}
