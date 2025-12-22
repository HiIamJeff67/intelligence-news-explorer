import Foundation
import SwiftData

@Model
class UserProfile {
    var id: String // Firebase UID
    var email: String
    var createdAt: Date
    @Relationship(deleteRule: .cascade) var activities: [UserActivity] = []
    
    init(id: String, email: String, createdAt: Date = Date()) {
        self.id = id
        self.email = email
        self.createdAt = createdAt
    }
}

@Model
class UserActivity {
    var type: ActivityType
    var timestamp: Date
    var metadata: String? // e.g., article title
    
    init(type: ActivityType, timestamp: Date = Date(), metadata: String? = nil) {
        self.type = type
        self.timestamp = timestamp
        self.metadata = metadata
    }
}

enum ActivityType: String, Codable {
    case summary
    case articleView
}
