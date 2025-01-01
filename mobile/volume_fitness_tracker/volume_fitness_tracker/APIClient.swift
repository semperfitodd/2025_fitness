import Foundation

struct APIClient {
    static func fetchData(for userEmail: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
        // Construct the URL from Secrets
        guard let url = URL(string: "\(Secrets.apiUrl)/get") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Secrets.apiToken, forHTTPHeaderField: "x-api-key")
        
        // Attach the request body
        let body: [String: Any] = ["user": userEmail]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(.failure(error))
            return
        }
        
        // Execute the API call
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Ensure response data is valid
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let data = data else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                completion(.failure(NSError(domain: "HTTP Error", code: statusCode, userInfo: nil)))
                return
            }
            
            // Parse the response JSON
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    completion(.success(json))
                } else {
                    completion(.failure(NSError(domain: "Invalid JSON Format", code: 0, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
