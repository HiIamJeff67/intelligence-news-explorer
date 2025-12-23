import Foundation

enum NewsAPIError: Error, LocalizedError {
    case missingAPIKey
    case invalidURL
    case invalidResponse
    case apiError(String)
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Missing NewsAPI key"
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid Response"
        case .apiError(let message):
            return message
        case .decodingError:
            return "Failed to decode response"
        }
    }
}

class NewsAPIClient {
    private let session: URLSession
    private let apiKey: String
    private let baseURL = "https://newsapi.org/v2"
    
    init(session: URLSession = .shared) throws {
        var key = Bundle.main.object(forInfoDictionaryKey: "NewsAPIKey") as? String
        
        if key == nil || key?.isEmpty == true,
           let path = Bundle.main.path(forResource: "NewsAPIConfig", ofType: "xcconfig"),
           let content = try? String(contentsOfFile: path, encoding: .utf8) {
            key = content.components(separatedBy: .newlines)
                .first(where: { $0.trimmingCharacters(in: .whitespaces).hasPrefix("NEWS_API_KEY") })?
                .components(separatedBy: "=").last?
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        guard let finalKey = key, !finalKey.isEmpty else { throw NewsAPIError.missingAPIKey }
        self.session = session
        self.apiKey = finalKey
    }
    
    func searchTopHeadlines(country: String = "us", category: String? = nil, pageSize: Int = 20) async throws -> [Article] {
        var components = URLComponents(string: "\(baseURL)/top-headlines")
        var queryItems = [
            URLQueryItem(name: "apiKey", value: apiKey),
            URLQueryItem(name: "country", value: country),
            URLQueryItem(name: "pageSize", value: String(pageSize))
        ]
        
        if let category = category {
            queryItems.append(URLQueryItem(name: "category", value: category))
        }
        
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            throw NewsAPIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NewsAPIError.invalidResponse
        }
        
        let newsResponse = try JSONDecoder().decode(NewsResponse.self, from: data)
        return newsResponse.articles
    }
    
    func searchEverything(q: String, from: Date? = nil, to: Date? = nil, sortBy: String = "publishedAt", language: String = "en", pageSize: Int = 20) async throws -> [Article] {
        var components = URLComponents(string: "\(baseURL)/everything")
        var queryItems = [
            URLQueryItem(name: "apiKey", value: apiKey),
            URLQueryItem(name: "sortBy", value: sortBy),
            URLQueryItem(name: "language", value: language),
            URLQueryItem(name: "pageSize", value: String(pageSize))
        ]
        
        if !q.isEmpty {
            queryItems.append(URLQueryItem(name: "q", value: q))
        } else {
             queryItems.append(URLQueryItem(name: "q", value: "news"))
        }
        
        if let from = from {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime]
            queryItems.append(URLQueryItem(name: "from", value: formatter.string(from: from)))
        }
        
        if let to = to {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime]
            queryItems.append(URLQueryItem(name: "to", value: formatter.string(from: to)))
        }
        
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            throw NewsAPIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NewsAPIError.invalidResponse
        }
        
        let newsResponse = try JSONDecoder().decode(NewsResponse.self, from: data)
        return newsResponse.articles
    }
}
