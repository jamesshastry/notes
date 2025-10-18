//
//  Note.swift
//  NotesIOSApp
//
//  Created on 2025-01-01.
//

import Foundation

struct Note: Identifiable, Codable {
    var id: Int?
    var userId: String
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var isFavorite: Bool
    var tags: [String]
    var attachments: [Attachment]
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case content
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case isFavorite = "is_favorite"
        case tags
        case attachments
    }
    
    init(id: Int? = nil, userId: String, title: String, content: String, createdAt: Date = Date(), updatedAt: Date = Date(), isFavorite: Bool = false, tags: [String] = [], attachments: [Attachment] = []) {
        self.id = id
        self.userId = userId
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isFavorite = isFavorite
        self.tags = tags
        self.attachments = attachments
    }
}

struct Attachment: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var path: String
    var size: Int64
    var type: String
    var url: String
    
    enum CodingKeys: String, CodingKey {
        case name, path, size, type, url
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(path)
    }
    
    static func == (lhs: Attachment, rhs: Attachment) -> Bool {
        lhs.id == rhs.id && lhs.path == rhs.path
    }
}

