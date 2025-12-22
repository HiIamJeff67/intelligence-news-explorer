import SwiftUI
import Combine

@MainActor
final class NewsViewModel: ObservableObject {
    @Published var topHeadlines: [Article] = []
    @Published var searchResults: [Article] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var client: NewsAPIClient?

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
}//
//  NewsViewModel.swift
//  IntelligentNewsExplorer
//
//  Created by HiIamJeff on 2025/12/22.
//
