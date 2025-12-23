import SwiftUI
import Combine

@MainActor
final class NewsViewModel: ObservableObject {
    @Published var topHeadlines: [Article] = []
    @Published var searchResults: [Article] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    @Published var summary: String = ""
    @Published var isSummarizing: Bool = false
    @Published var aiErrorMessage: String?
    @Published var showAIError: Bool = false

    private var client: NewsAPIClient?
    private let aiService = AIService()

    init() {
        do {
            self.client = try NewsAPIClient()
        } catch {
            self.errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            self.client = nil
        }
    }

    func loadTopHeadlines() async {
        guard let client = client else { return }
        isLoading = true
        errorMessage = nil
        do {
            let headlines = try await client.searchTopHeadlines(country: "us", category: nil, pageSize: 20)
            self.topHeadlines = headlines
        } catch {
            self.errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            self.topHeadlines = []
        }
        isLoading = false
    }
    
    func searchArticles(query: String) async {
        guard let client = client else { return }
        isLoading = true
        errorMessage = nil
        do {
            let articles = try await client.searchEverything(q: query, pageSize: 30)
            self.searchResults = articles
        } catch {
            self.errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            self.searchResults = []
        }
        isLoading = false
    }
    
    func summarizeHeadlines() async {
        guard !topHeadlines.isEmpty else { return }
        
        isSummarizing = true
        aiErrorMessage = nil
        summary = ""
        
        let headlinesText = topHeadlines.prefix(10).map { $0.title }.joined(separator: "\n- ")
        
        do {
            let result = try await aiService.summarize(text: headlinesText)
            self.summary = result
        } catch {
            self.aiErrorMessage = error.localizedDescription
            self.showAIError = true
        }
        
        isSummarizing = false
    }
}
