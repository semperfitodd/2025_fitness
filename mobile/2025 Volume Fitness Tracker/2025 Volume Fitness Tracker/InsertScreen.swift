import SwiftUI

struct InsertScreen: View {
    var body: some View {
        VStack {
            Text("Insert Screen")
                .font(.title)
                .padding()

            // Example usage of ExerciseData
            List {
                ForEach([ExerciseData(exercise: "Bench Press", value: 5000)], id: \.id) { data in
                    Text("\(data.exercise): \(data.value) lbs")
                }
            }
        }
    }
}
