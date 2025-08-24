import Foundation

// MARK: - Watch App API Client
struct WatchAPIClient {
    static func fetchData(for userEmail: String, completion: @escaping (Result<FitnessDataResponse, WatchAPIError>) -> Void) {
        // Get API configuration
        let apiUrl = WatchSecrets.apiUrl
        let apiToken = WatchSecrets.apiToken
        
        // Construct the URL
        guard let url = URL(string: "\(apiUrl)/get") else {
            completion(.failure(.invalidURL))
            return
        }
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiToken, forHTTPHeaderField: "x-api-key")
        request.setValue(userEmail, forHTTPHeaderField: "x-user-email")
        
        // Debug logging
        print("⌚ Watch API Request:")
        print("URL: \(url)")
        print("API Token: \(apiToken.prefix(10))...")
        print("User Email: \(userEmail)")
        
        // Create request body
        let requestBody = ["user": userEmail]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
            request.httpBody = jsonData
        } catch {
            completion(.failure(.serializationError(error)))
            return
        }
        
        // Make the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle network error
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            // Handle HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            // Debug logging
            print("⌚ Watch API Response:")
            print("Status: \(httpResponse.statusCode)")
            print("Headers: \(httpResponse.allHeaderFields)")
            
            // Check status code
            guard (200...299).contains(httpResponse.statusCode) else {
                print("⌚ Watch API Error: HTTP \(httpResponse.statusCode)")
                completion(.failure(.httpError(httpResponse.statusCode)))
                return
            }
            
            // Check for data
            guard let data = data else {
                print("⌚ Watch API Error: No data received")
                completion(.failure(.noData))
                return
            }
            
            // Debug logging
            if let responseString = String(data: data, encoding: .utf8) {
                print("⌚ Watch API Response Body: \(responseString)")
            }
            
            // Parse JSON response using Codable
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(FitnessDataResponse.self, from: data)
                print("⌚ Watch API Success: Decoded response")
                completion(.success(response))
            } catch {
                print("⌚ Watch API Decoding Error: \(error)")
                completion(.failure(.decodingError(error)))
            }
        }
        
        task.resume()
    }
}



// MARK: - Watch App Secrets (Shared with iOS app)
enum WatchSecrets {
    static let apiUrl: String = {
        // Try to find Secrets.plist in the main bundle (shared with iOS app)
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dictionary = NSDictionary(contentsOfFile: path) as? [String: Any],
              let apiUrl = dictionary["API_URL"] as? String else {
            print("⌚ Watch App: Failed to load API_URL from Secrets.plist")
            print("⌚ Watch App: Bundle path: \(Bundle.main.bundlePath)")
            print("⌚ Watch App: Available resources: \(Bundle.main.paths(forResourcesOfType: "plist", inDirectory: nil))")
            fatalError("API_URL is not set or Secrets.plist is missing! Make sure Secrets.plist is added to both iOS and Watch targets.")
        }
        print("⌚ Watch App: Successfully loaded API_URL: \(apiUrl)")
        return apiUrl
    }()

    static let apiToken: String = {
        // Try to find Secrets.plist in the main bundle (shared with iOS app)
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dictionary = NSDictionary(contentsOfFile: path) as? [String: Any],
              let apiToken = dictionary["API_TOKEN"] as? String else {
            print("⌚ Watch App: Failed to load API_TOKEN from Secrets.plist")
            fatalError("API_TOKEN is not set or Secrets.plist is missing! Make sure Secrets.plist is added to both iOS and Watch targets.")
        }
        print("⌚ Watch App: Successfully loaded API_TOKEN: \(apiToken.prefix(10))...")
        return apiToken
    }()
}
