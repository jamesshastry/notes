//
//  UserProfile.swift
//  NotesIOSApp
//
//  Created on 2025-01-01.
//

import Foundation

struct UserProfile: Codable {
    var userId: String
    var email: String
    var name: String?
    var isPremium: Bool
    var premiumSince: Date?
    var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email
        case name
        case isPremium = "is_premium"
        case premiumSince = "premium_since"
        case createdAt = "created_at"
    }
}

struct SubscriptionStatus: Codable {
    var id: Int?
    var userId: String
    var userEmail: String
    var subscriptionId: String?
    var status: Bool
    var paymentId: String?
    var checkoutSessionId: String?
    var totalAmount: Double?
    var currency: String?
    var paymentMethod: String?
    var paymentStatus: String?
    var createdAt: Date?
    var updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case userEmail = "user_email"
        case subscriptionId = "subscription_id"
        case status
        case paymentId = "payment_id"
        case checkoutSessionId = "checkout_session_id"
        case totalAmount = "total_amount"
        case currency
        case paymentMethod = "payment_method"
        case paymentStatus = "payment_status"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

