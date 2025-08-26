import Foundation

// MARK: - Watch App API Client
struct WatchAPIClient {
    static func fetchData(for userEmail: String, completion: @escaping (Result<FitnessDataResponse, SharedAPIError>) -> Void) {
        // Get API configuration
        let apiUrl = Secrets.apiUrl
        let apiToken = Secrets.apiToken
        
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
        print("\(SharedConstants.Logging.watchPrefix) API Request:")
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
            print("\(SharedConstants.Logging.watchPrefix) API Response:")
            print("Status: \(httpResponse.statusCode)")
            print("Headers: \(httpResponse.allHeaderFields)")
            
            // Check status code
            guard (200...299).contains(httpResponse.statusCode) else {
                print("\(SharedConstants.Logging.watchPrefix) API Error: HTTP \(httpResponse.statusCode)")
                completion(.failure(.httpError(httpResponse.statusCode)))
                return
            }
            
            // Check for data
            guard let data = data else {
                print("\(SharedConstants.Logging.watchPrefix) API Error: No data received")
                completion(.failure(.noData))
                return
            }
            
            // Debug logging
            if let responseString = String(data: data, encoding: .utf8) {
                print("\(SharedConstants.Logging.watchPrefix) API Response Body: \(responseString)")
            }
            
            // Parse JSON response using Codable
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(FitnessDataResponse.self, from: data)
                print("\(SharedConstants.Logging.watchPrefix) API Success: Decoded response")
                completion(.success(response))
            } catch {
                print("\(SharedConstants.Logging.watchPrefix) API Decoding Error: \(error)")
                completion(.failure(.decodingError(error)))
            }
        }
        
        task.resume()
    }
}




