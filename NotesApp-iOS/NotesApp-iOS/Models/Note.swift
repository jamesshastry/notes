import Foundation

struct Note: Codable, Identifiable {
    let id: Int
    let userId: String
    let title: String
    let content: String
    let isFavorite: Bool
    let tags: [String]
    let attachments: [Attachment]?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case content
        case isFavorite = "is_favorite"
        case tags
        case attachments
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct Attachment: Codable {
    let name: String
    let path: String
    let size: Int
    let type: String
    let url: String
}

struct NoteCreate: Codable {
    let title: String
    let content: String
    let userId: String
    let isFavorite: Bool
    let tags: [String]
    let attachments: [Attachment]
    
    enum CodingKeys: String, CodingKey {
        case title
        case content
        case userId = "user_id"
        case isFavorite = "is_favorite"
        case tags
        case attachments
    }
}

struct NoteUpdate: Codable {
    let title: String
    let content: String
    let attachments: [Attachment]?
}

struct UserProfile: Codable {
    let id: String?
    let userId: String
    let email: String
    let name: String?
    let isPremium: Bool
    let premiumSince: String?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case email
        case name
        case isPremium = "is_premium"
        case premiumSince = "premium_since"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

