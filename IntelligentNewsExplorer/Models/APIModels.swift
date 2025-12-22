import Foundation

// MARK: - Chat Completion Models

struct ChatCompletionRequest: Codable {
    let model: String
    let messages: [APIMessage]
    var stream: Bool? = false
    var temperature: Double? = 0.7
    var max_tokens: Int? = 500
}

struct APIMessage: Codable {
    let role: String
    let content: String
}

struct ChatCompletionResponse: Codable {
    let id: String
    let choices: [Choice]
}

struct Choice: Codable {
    let message: APIMessage
}

// MARK: - Streaming Models

struct StreamResponse: Codable {
    let choices: [StreamChoice]
}

struct StreamChoice: Codable {
    let delta: StreamDelta
    let finish_reason: String?
}

struct StreamDelta: Codable {
    let content: String?
}

// MARK: - Models API Models

struct ModelListResponse: Codable {
    let data: [ModelInfo]
}

struct ModelInfo: Codable, Identifiable {
    let id: String
    let name: String?
}
