import Foundation
import FoundationModels

actor AIService {
    private let model = SystemLanguageModel.default
    
    func getModel() -> SystemLanguageModel {
        return model
    }
    
    func checkAvailability() throws {
        switch model.availability {
        case .available:
            return
        case .unavailable(let reason):
            let message: String
            switch reason {
            case .deviceNotEligible: message = "Device not eligible (裝置不支援)"
            case .appleIntelligenceNotEnabled: message = "Apple Intelligence not enabled (未啟用 Apple Intelligence)"
            case .modelNotReady: message = "Model not ready (模型正在下載或準備中)"
            @unknown default: message = "Unavailable (Unknown reason)"
            }
            throw NSError(domain: "AIService", code: 1, userInfo: [NSLocalizedDescriptionKey: message])
        @unknown default:
            throw NSError(domain: "AIService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Status unknown"])
        }
    }
    
    func summarize(article: Article) async throws -> String {
        let articleContent = """
        title: \(article.title)
        source.id: \(article.source.id ?? "")
        source.name: \(article.source.name)
        author: \(article.author ?? "")
        url: \(article.url)
        urlToImage: \(article.urlToImage ?? "")
        publishedAt: \(article.publishedAt)
        description: \(article.description ?? "")
        content: \(article.content ?? "")
        """
        
        let prompt = "Summarize the following news article and generate a structured Article (with title, description, source, url, publishedAt, content, etc.):\n\n\(articleContent)"
        
        let session = LanguageModelSession(model: model)
        let stream = session.streamResponse(to: prompt, generating: Article.self)
        var result: Article.PartiallyGenerated? = nil
        for try await partial in stream {
            result = partial.content
        }
        if let final = result {
            var dict: [String: Any] = [:]
            dict["title"] = final.title
            dict["author"] = final.author
            dict["url"] = final.url
            dict["urlToImage"] = final.urlToImage
            dict["publishedAt"] = final.publishedAt
            dict["description"] = final.description
            dict["content"] = final.content
            if let source = final.source {
                dict["source"] = [
                    "id": source.id as Any,
                    "name": source.name as Any
                ]
            }
            let data = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            return String(data: data, encoding: .utf8) ?? ""
        } else {
            throw NSError(domain: "AIService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to generate structured Article"])
        }
    }
    
    func summarize(text: String) async throws -> String {
        try checkAvailability()
        
        let cleanText = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\r\n", with: "\n")
        
        let prompt = "Summarize the following news headlines based one the following content, generate a structured Article (with title, description, source, url, publishedAt, content, etc:\n\n\(cleanText)"
        
        print("Sending Prompt (\(prompt.count) chars): \(prompt.prefix(50))...")
        
        let session = LanguageModelSession(model: model)
        
        do {
            let response = try await session.respond(to: prompt)
            return response.content
        } catch let nsError as NSError {
            var detailedMessage = "System Error (Code \(nsError.code))"
            
            if let underlyingErrors = nsError.userInfo[NSMultipleUnderlyingErrorsKey] as? [NSError],
               let firstError = underlyingErrors.first {
                detailedMessage = "Core Error: \(firstError.domain) (Code \(firstError.code))\n\(firstError.localizedDescription)"
            } else if let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? NSError {
                detailedMessage = "Core Error: \(underlyingError.domain) (Code \(underlyingError.code))\n\(underlyingError.localizedDescription)"
            }
            
            print("Deep Error Extraction: \(detailedMessage)")
            throw nsError
        }
    }
    
    func summarizeToSummary(article: Article) async throws -> Summary.PartiallyGenerated {
        try checkAvailability()
        let contentParts = [
            article.title,
            article.source.name,
            article.author ?? "",
            article.url,
            article.description ?? "",
            article.content ?? ""
        ]
        let textToSummarize = contentParts.joined(separator: "\n\n")
        let prompt = "請根據以下新聞內容，產生一個結構化的 Summary，包括 summaryText、highlights、headline、icon、callToAction：\n\n\(textToSummarize)"
        let session = LanguageModelSession(model: model)
        let stream = session.streamResponse(to: prompt, generating: Summary.self)
        var result: Summary.PartiallyGenerated? = nil
        for try await partial in stream {
            result = partial.content
        }
        if let final = result {
            return final
        } else {
            throw NSError(domain: "AIService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Failed to generate structured Summary"])
        }
    }
}
