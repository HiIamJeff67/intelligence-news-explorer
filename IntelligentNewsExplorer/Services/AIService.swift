import Foundation
import FoundationModels

actor AIService {
    private let model = SystemLanguageModel.default
    
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
    
    func summarize(text: String) async throws -> String {
        try checkAvailability()
        
        let cleanText = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "\r\n", with: "\n")
        
        let prompt = "Summarize the following news headlines:\n\n\(cleanText)"
        
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
}
