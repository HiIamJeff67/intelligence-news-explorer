import Foundation
import FoundationModels

struct NewsResponse: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

@Generable
struct Summary {
    @Guide(description: "A concise summary of the news article, suitable for quick reading.")
    var summaryText: String
    
    @Guide(description: "A list of 2-4 key points or highlights from the article.", .count(2...4))
    var highlights: [String]
    
    @Guide(description: "A short, catchy headline for the summary.")
    var headline: String
    
    @Guide(description: "A suggested emoji or icon that represents the article's mood or topic.")
    var icon: String?
    
    @Guide(description: "A call-to-action or suggested next step for the reader, e.g., 'Read more', 'Share this', etc.")
    var callToAction: String?
}

@Generable
struct Article: Codable, Identifiable, Equatable {
    var id = UUID()
    
    @Guide(description: "The source of the news article.")
    var source: Source
    
    @Guide(description: "The author of the article.")
    var author: String?
    
    @Guide(description: "The headline or title of the article.")
    var title: String
    
    @Guide(description: "A short description or summary of the article.")
    var description: String?
    
    @Guide(description: "The URL to the full article.")
    var url: String
    
    @Guide(description: "The URL to the article's image.")
    var urlToImage: String?
    
    @Guide(description: "The publication date in ISO 8601 format.")
    var publishedAt: String
    
    @Guide(description: "The content of the article.")
    var content: String?
    
    enum CodingKeys: String, CodingKey {
        case source, author, title, description, url, urlToImage, publishedAt, content
    }
}

@Generable
struct Source: Codable, Equatable {
    @Guide(description: "The identifier of the source.")
    var id: String?
    
    @Guide(description: "The name of the news source.")
    var name: String
}
