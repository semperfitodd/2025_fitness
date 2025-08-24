import Foundation

// MARK: - API Client Protocol
protocol APIClientProtocol {
    func fetchFitnessData(for userEmail: String) async throws -> FitnessDataResponse
    func submitWorkout(_ workout: WorkoutSubmission) async throws -> WorkoutResponse
    func generateWorkout() async throws -> WorkoutPlanResponse
}

// MARK: - API Response Models
struct WorkoutResponse: Codable {
    let message: String
    let user: String
    let date: String
    let totalVolume: Double
    let exerciseVolumes: [String: Double]
    let exerciseReps: [String: Int]
    
    enum CodingKeys: String, CodingKey {
        case message, user, date
        case totalVolume = "total_volume"
        case exerciseVolumes = "exercise_volumes"
        case exerciseReps = "exercise_reps"
    }
}

// MARK: - API Client Implementation
class APIClient: APIClientProtocol {
    private let baseURL: String
    private let apiKey: String
    private let session: URLSession
    
    init(baseURL: String = Secrets.apiUrl, apiKey: String = Secrets.apiToken, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.session = session
    }
    
    // MARK: - Fitness Data
    func fetchFitnessData(for userEmail: String) async throws -> FitnessDataResponse {
        let endpoint = "\(baseURL)/get"
        let body = ["user": userEmail]
        
        return try await performRequest(
            url: endpoint,
            method: "POST",
            body: body,
            responseType: FitnessDataResponse.self,
            userEmail: userEmail
        )
    }
    
    // MARK: - Submit Workout
    func submitWorkout(_ workout: WorkoutSubmission) async throws -> WorkoutResponse {
        let endpoint = "\(baseURL)/post"
        
        return try await performRequest(
            url: endpoint,
            method: "POST",
            body: workout,
            responseType: WorkoutResponse.self,
            userEmail: workout.user
        )
    }
    
    // MARK: - Generate Workout
    func generateWorkout() async throws -> WorkoutPlanResponse {
        let endpoint = "\(baseURL)/claude"
        
        return try await performGetRequest(
            url: endpoint,
            responseType: WorkoutPlanResponse.self
        )
    }
    
    // MARK: - Private Helper Methods
    private func performGetRequest<U: Codable>(
        url: String,
        responseType: U.Type
    ) async throws -> U {
        guard let url = URL(string: url) else {
            throw FitnessError.invalidData("Invalid URL: \(url)")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        // Debug logging
        print("🌐 iOS API GET Request:")
        print("URL: \(url)")
        print("Headers: \(request.allHTTPHeaderFields ?? [:])")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            // Debug logging
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 iOS API GET Response:")
                print("Status: \(httpResponse.statusCode)")
                print("Headers: \(httpResponse.allHeaderFields)")
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response Body: \(responseString)")
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw FitnessError.networkError("Invalid response type")
            }
            
            // Handle different status codes
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decodedResponse = try JSONDecoder().decode(responseType, from: data)
                    return decodedResponse
                } catch {
                    print("❌ GET Decoding Error: \(error)")
                    throw FitnessError.invalidData("Failed to decode response: \(error.localizedDescription)")
                }
            case 401:
                throw FitnessError.authenticationError("Authentication failed")
            case 403:
                throw FitnessError.authenticationError("Access denied")
            case 400:
                throw FitnessError.invalidData("Bad request")
            case 500...599:
                throw FitnessError.serverError("Server error: \(httpResponse.statusCode)")
            default:
                throw FitnessError.unknownError("Unexpected status code: \(httpResponse.statusCode)")
            }
        } catch {
            print("❌ GET Network Error: \(error)")
            if let fitnessError = error as? FitnessError {
                throw fitnessError
            } else {
                throw FitnessError.networkError(error.localizedDescription)
            }
        }
    }
    
    private func performRequest<T: Codable, U: Codable>(
        url: String,
        method: String,
        body: T?,
        responseType: U.Type,
        userEmail: String? = nil
    ) async throws -> U {
        guard let url = URL(string: url) else {
            throw FitnessError.invalidData("Invalid URL: \(url)")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        // Add x-user-email header if provided (matches React app)
        if let userEmail = userEmail {
            request.setValue(userEmail, forHTTPHeaderField: "x-user-email")
        }
        
        // Debug logging
        print("🌐 iOS API Request:")
        print("URL: \(url)")
        print("Method: \(method)")
        print("Headers: \(request.allHTTPHeaderFields ?? [:])")
        
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
                if let bodyString = String(data: request.httpBody!, encoding: .utf8) {
                    print("Body: \(bodyString)")
                }
            } catch {
                throw FitnessError.invalidData("Failed to encode request body: \(error.localizedDescription)")
            }
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            // Debug logging
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 iOS API Response:")
                print("Status: \(httpResponse.statusCode)")
                print("Headers: \(httpResponse.allHeaderFields)")
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("Response Body: \(responseString)")
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw FitnessError.networkError("Invalid response type")
            }
            
            // Handle different status codes
            switch httpResponse.statusCode {
            case 200...299:
                do {
                    let decodedResponse = try JSONDecoder().decode(responseType, from: data)
                    return decodedResponse
                } catch {
                    print("❌ Decoding Error: \(error)")
                    throw FitnessError.invalidData("Failed to decode response: \(error.localizedDescription)")
                }
            case 401:
                throw FitnessError.authenticationError("Authentication failed")
            case 403:
                throw FitnessError.authenticationError("Access denied")
            case 400:
                throw FitnessError.invalidData("Bad request")
            case 500...599:
                throw FitnessError.serverError("Server error: \(httpResponse.statusCode)")
            default:
                throw FitnessError.unknownError("Unexpected status code: \(httpResponse.statusCode)")
            }
        } catch {
            print("❌ Network Error: \(error)")
            if let fitnessError = error as? FitnessError {
                throw fitnessError
            } else {
                throw FitnessError.networkError(error.localizedDescription)
            }
        }
    }
}

// MARK: - Mock API Client for Testing
class MockAPIClient: APIClientProtocol {
    var shouldSucceed = true
    var mockFitnessData: FitnessDataResponse?
    var mockWorkoutResponse: WorkoutResponse?
    var mockWorkoutPlan: WorkoutPlanResponse?
    
    func fetchFitnessData(for userEmail: String) async throws -> FitnessDataResponse {
        if shouldSucceed {
            return mockFitnessData ?? FitnessDataResponse(
                user: userEmail,
                exerciseData: [:],
                totalLifted: 0
            )
        } else {
            throw FitnessError.networkError("Mock network error")
        }
    }
    
    func submitWorkout(_ workout: WorkoutSubmission) async throws -> WorkoutResponse {
        if shouldSucceed {
            return mockWorkoutResponse ?? WorkoutResponse(
                message: "Workout submitted successfully",
                user: workout.user,
                date: workout.date,
                totalVolume: workout.exercises.reduce(0) { $0 + ($1.weight * Double($1.reps)) },
                exerciseVolumes: [:],
                exerciseReps: [:]
            )
        } else {
            throw FitnessError.networkError("Mock network error")
        }
    }
    
    func generateWorkout() async throws -> WorkoutPlanResponse {
        if shouldSucceed {
            return mockWorkoutPlan ?? WorkoutPlanResponse(workoutPlan: "Mock workout plan")
        } else {
            throw FitnessError.networkError("Mock network error")
        }
    }
}
