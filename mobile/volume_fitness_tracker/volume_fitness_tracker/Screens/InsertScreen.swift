import SwiftUI

struct InsertScreen: View {
    let userEmail: String
    @StateObject private var viewModel: InsertViewModel
    
    init(userEmail: String) {
        self.userEmail = userEmail
        self._viewModel = StateObject(wrappedValue: InsertViewModel(userEmail: userEmail))
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 20) {
                        if viewModel.isLoading {
                            LoadingView("Submitting workout...")
                        } else {
                            contentView
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Add Workout")
            .navigationBarTitleDisplayMode(.large)
            .errorAlert(errorMessage: viewModel.errorMessage) {
                viewModel.clearError()
            }
            .alert("Success", isPresented: $viewModel.showConfirmation) {
                Button("OK") {
                    viewModel.clearSuccess()
                }
            } message: {
                if let successMessage = viewModel.successMessage {
                    Text(successMessage)
                }
            }
        }
    }
    
    private var contentView: some View {
        VStack(spacing: 20) {
            // Header
            headerSection
            
            // Date Picker
            dateSection
            
            // Exercises List
            exercisesSection
            
            // Action Buttons
            actionButtons
            
            // Total Volume
            totalVolumeSection
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Add Workout")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Record your exercises and track your progress")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var dateSection: some View {
        VStack(spacing: 12) {
            Button(action: viewModel.toggleDatePicker) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                    
                    Text("Date: \(viewModel.formatDate(date: viewModel.date))")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Image(systemName: viewModel.isDatePickerExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            
            if viewModel.isDatePickerExpanded {
                DatePicker("", selection: $viewModel.date, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }
        }
    }
    
    private var exercisesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Exercises")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(viewModel.exercises.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
            }
            
            LazyVStack(spacing: 12) {
                ForEach(Array(viewModel.exercises.enumerated()), id: \.element.id) { index, exercise in
                    ExerciseRowView(
                        exercise: Binding(
                            get: { exercise },
                            set: { viewModel.updateExercise($0, at: index) }
                        ),
                        onRemove: {
                            viewModel.removeExercise(at: index)
                        }
                    )
                }
            }
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: viewModel.addExercise) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Exercise")
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            LoadingButton(
                title: "Submit Workout",
                isLoading: viewModel.isLoading
            ) {
                Task {
                    await viewModel.submitWorkout()
                }
            }
        }
    }
    
    private var totalVolumeSection: some View {
        VStack(spacing: 8) {
            Text("Total Volume")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text("\(viewModel.totalVolume, specifier: "%.1f") lbs")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.blue)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ExerciseRowView: View {
    @Binding var exercise: Exercise
    let onRemove: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                TextField("Exercise Name", text: Binding(
                    get: { exercise.name },
                    set: { exercise.name = $0.lowercased() }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disableAutocorrection(true)
                .autocapitalization(.none)
                
                Button(action: onRemove) {
                    Image(systemName: "trash.circle.fill")
                        .foregroundColor(.red)
                        .font(.title2)
                }
            }
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Weight (lbs)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextField("0", value: $exercise.weight, formatter: weightFormatter)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Reps")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextField("0", value: $exercise.reps, formatter: repsFormatter)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
            }
            
            if !exercise.isValid && !exercise.name.isEmpty {
                Text("Volume: \(exercise.volume, specifier: "%.1f") lbs")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var weightFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimum = 0
        return formatter
    }
    
    private var repsFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.minimum = 0
        return formatter
    }
}

#Preview {
    InsertScreen(userEmail: "test@example.com")
}
