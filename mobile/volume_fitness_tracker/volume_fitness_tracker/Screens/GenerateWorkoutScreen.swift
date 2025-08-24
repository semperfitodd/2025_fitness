import SwiftUI

struct GenerateWorkoutScreen: View {
    let userEmail: String
    @StateObject private var viewModel: GenerateWorkoutViewModel
    
    init(userEmail: String) {
        self.userEmail = userEmail
        self._viewModel = StateObject(wrappedValue: GenerateWorkoutViewModel())
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if viewModel.isLoading {
                    LoadingView("Generating your workout plan...")
                } else {
                    contentView
                }
            }
            .padding()
            .navigationTitle("Generate Workout")
            .navigationBarTitleDisplayMode(.large)
            .errorAlert(errorMessage: viewModel.errorMessage) {
                viewModel.clearError()
            }
        }
    }
    
    private var contentView: some View {
        VStack(spacing: 24) {
            // Header
            headerSection
            
            // Workout Plan Display
            workoutPlanSection
            
            // Action Buttons
            actionButtons
            
            Spacer()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "dumbbell.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text("AI Workout Generator")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Get personalized workout plans based on your fitness goals and preferences")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var workoutPlanSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if viewModel.hasGeneratedWorkout {
                HStack {
                    Text("Your Workout Plan")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button("Clear") {
                        viewModel.clearWorkout()
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                }
                
                ScrollView {
                    Text(viewModel.workoutPlan)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                .frame(maxHeight: 400)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                    
                    Text("Ready to get started?")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Tap the button below to generate a personalized workout plan tailored to your fitness goals.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            LoadingButton(
                title: viewModel.hasGeneratedWorkout ? "Generate New Plan" : "Generate Workout Plan",
                isLoading: viewModel.isLoading
            ) {
                Task {
                    await viewModel.generateWorkout()
                }
            }
            
            if viewModel.hasGeneratedWorkout {
                Button("Clear Plan") {
                    viewModel.clearWorkout()
                }
                .font(.subheadline)
                .foregroundColor(.red)
            }
        }
    }
}

#Preview {
    GenerateWorkoutScreen(userEmail: "test@example.com")
}
