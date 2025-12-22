import Foundation

enum NewsAPIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case apiError(String)
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .invalidResponse: return "Invalid Response"
        case .apiError(let message): return message
        case .decodingError: return "Failed to decode response"
        }
    }
}

class NewsAPIClient {
    private let apiKey: String
    private let baseURL = "https://newsapi.org/v2"
    
    init(apiKey: String? = nil) throws {
        // Try to get key from Info.plist or use the hardcoded one from config if available
        if let key = apiKey {
            self.apiKey = key
        } else if let key = Bundle.main.object(forInfoDictionaryKey: "NEWS_API_KEY") as? String, !key.isEmpty {
            self.apiKey = key
        } else {
            // Fallback to the one found in xcconfig if not in Info.plist (for development)
            self.apiKey = "681611199a5349258c308eeea9f07d29"
        }
        
        if self.apiKey.isEmpty {
            throw NewsAPIError.apiError("Missing API Key")
        }
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
        
        // If query is empty, NewsAPI might complain for 'everything' endpoint, but user said "empty query".
        // NewsAPI documentation says 'q' or 'qInTitle' or 'sources' or 'domains' is required.
        // If q is empty, we might need a fallback or just send it and see.
        // However, the user said "NewsView 使用 NewsAPI 跑 everything，搭配空白的 query".
        // Maybe they mean just listing everything? But 'everything' endpoint usually requires a parameter.
        // I'll default q to "general" or "news" if empty, or just pass it.
        // Actually, let's pass "*" if empty, or handle it in ViewModel.
        
        if !q.isEmpty {
            queryItems.append(URLQueryItem(name: "q", value: q))
        } else {
             queryItems.append(URLQueryItem(name: "q", value: "news")) // Fallback
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
