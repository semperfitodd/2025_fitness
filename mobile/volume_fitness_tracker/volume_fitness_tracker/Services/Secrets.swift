import Foundation

enum Secrets {
    static let apiUrl: String = {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dictionary = NSDictionary(contentsOfFile: path) as? [String: Any],
              let apiUrl = dictionary["API_URL"] as? String else {
            fatalError("API_URL is not set or Secrets.plist is missing!")
        }
        print("API_URL fetched: \(apiUrl)")
        return apiUrl
    }()

    static let apiToken: String = {
        guard let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let dictionary = NSDictionary(contentsOfFile: path) as? [String: Any],
              let apiToken = dictionary["API_TOKEN"] as? String else {
            fatalError("API_TOKEN is not set or Secrets.plist is missing!")
        }
        print("API_TOKEN fetched: \(apiToken)")
        return apiToken
    }()
}
