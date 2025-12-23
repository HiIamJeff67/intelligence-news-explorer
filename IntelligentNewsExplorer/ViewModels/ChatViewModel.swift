import SwiftUI
import FoundationModels
import Combine

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let role: MessageRole
    let content: String
    
    enum MessageRole {
        case user
        case assistant
    }
}

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var input: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let articles: [Article]
    private let initialSummary: String
    private var session: LanguageModelSession?
    private let model = SystemLanguageModel.default
    
    init(articles: [Article], initialSummary: String) {
        self.articles = articles
        self.initialSummary = initialSummary
        self.messages = [
            ChatMessage(role: .assistant, content: initialSummary)
        ]
    }
    
    func sendMessage() async {
        guard !input.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = input
        input = ""
        
        messages.append(ChatMessage(role: .user, content: userMessage))
        
        isLoading = true
        errorMessage = nil
        
        do {
            if session == nil {
                try await initializeSession()
            }
            
            guard let session = session else {
                throw NSError(domain: "ChatViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to initialize session"])
            }
            
            let prompt: String
            if messages.filter({ $0.role == .user }).count == 1 {
                let articlesContext = articles.map { article in
                    """
                    Title: \(article.title)
                    Source: \(article.source.name)
                    Description: \(article.description ?? "N/A")
                    Content: \(article.content ?? "N/A")
                    """
                }.joined(separator: "\n---\n")
                
                prompt = """
                Here are the full news articles for context:
                
                \(articlesContext)
                
                Here is the summary you provided:
                \(initialSummary)
                
                User Question: \(userMessage)
                """
            } else {
                prompt = userMessage
            }
            
            let response = try await session.respond(to: prompt)
            
            messages.append(ChatMessage(role: .assistant, content: response.content))
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    private func initializeSession() async throws {
        if case let .unavailable(reason) = model.availability {
             let message: String
             switch reason {
             case .deviceNotEligible: message = "Device not eligible"
             case .appleIntelligenceNotEnabled: message = "Apple Intelligence not enabled"
             case .modelNotReady: message = "Model not ready"
             @unknown default: message = "Unavailable"
             }
             throw NSError(domain: "ChatViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: message])
        }
        
        self.session = LanguageModelSession(model: model)
    }
    
    private func handleError(_ error: Error) {
        if let nsError = error as? NSError {
            var detailedMessage = "System Error (Code \(nsError.code))"
            
            if let underlyingErrors = nsError.userInfo[NSMultipleUnderlyingErrorsKey] as? [NSError],
               let firstError = underlyingErrors.first {
                detailedMessage = "Core Error: \(firstError.domain) (Code \(firstError.code))"
            }
            print("Chat Error: \(detailedMessage)")
            self.errorMessage = detailedMessage
        } else {
            self.errorMessage = error.localizedDescription
        }
    }
}
