//
//  UserManager.swift
//  FirebaseMap
//
//  Created by Artem Golovchenko on 2024-12-09.
//

import Foundation
import FirebaseFirestore

struct DBUser: Codable {
    let userId: String
    let isAnonymous: Bool?
    let dateCreated: Date?
    let email: String?
    let photoUrl: String?
    let name: String?
    let isPremium: Bool?
    
    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.email = auth.email
        self.dateCreated = Date()
        self.isAnonymous = auth.isAnonymous
        self.photoUrl = auth.photoUrl
        self.name = auth.name
        self.isPremium = false
    }
    
    init(userId: String, isAnonymous: Bool? = nil, dateCreated: Date? = nil, email: String? = nil, photoUrl: String? = nil, name: String? = nil, isPremium: Bool? = nil) {
        self.userId = userId
        self.isAnonymous = isAnonymous
        self.dateCreated = dateCreated
        self.email = email
        self.photoUrl = photoUrl
        self.name = name
        self.isPremium = isPremium
    }
    
//    func togglePremiumStatus() -> DBUser {
//        let currentValue = isPremium ?? false
//        return DBUser(
//            userId: userId,
//            isAnonymous: isAnonymous,
//            dateCreated: dateCreated,
//            email: email,
//            photoUrl: photoUrl,
//            name: name,
//            isPremium: !currentValue)
//    }
    
//    mutating func togglePremiumStatus() {
//        let currentValue = isPremium ?? false
//        isPremium = !currentValue
//    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case isAnonymous = "is_anonymous"
        case dateCreated = "date_created"
        case email = "email"
        case photoUrl = "photo_url"
        case name = "name"
        case isPremium = "user_isPremium"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.isAnonymous = try container.decodeIfPresent(Bool.self, forKey: .isAnonymous)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.isPremium = try container.decodeIfPresent(Bool.self, forKey: .isPremium)
    }

    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.isAnonymous, forKey: .isAnonymous)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.photoUrl, forKey: .photoUrl)
        try container.encodeIfPresent(self.name, forKey: .name)
        try container.encodeIfPresent(self.isPremium, forKey: .isPremium)
    }
    
}

final class UserManager {
    
    static let shared = UserManager()
    private init() { }
    
    private let userCollection = Firestore.firestore().collection("users")
    
    private func userDocument(userid: String) -> DocumentReference {
        userCollection.document(userid)
    }
    
//    private let encoder: Firestore.Encoder = {
//        let encoder = Firestore.Encoder()
//        encoder.keyEncodingStrategy = .convertToSnakeCase
//        return encoder
//    }()
//    
//    private let decoder: Firestore.Decoder = {
//        let decoder = Firestore.Decoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
//        return decoder
//    }()
    
    func createNewUser(user: DBUser) async throws {
        try userDocument(userid: user.userId).setData(from: user, merge: false)
    }
    
//    func createNewUser(auth: AuthDataResultModel) async throws {
//        var userData: [String : Any] = [
//            "user_id" : auth.uid,
//            "is_anonymous" : auth.isAnonymous,
//            "date_created" : Timestamp(),
//        ]
//        if let email = auth.email {
//            userData["email"] = email
//        }
//        if let name = auth.name {
//            userData["name"] = name
//        }
//        if let photoUrl = auth.photoUrl {
//            userData["photo_url"] = photoUrl
//        }
//        try await userDocument(userid: auth.uid).setData(userData, merge: false)
//    }
    
    func getUser(userId: String) async throws -> DBUser {
        try await userDocument(userid: userId).getDocument(as: DBUser.self)
    }
    
//    func getUser(by userId: String) async throws -> DBUser {
//        
//        let snapshot = try await userDocument(userid: userId).getDocument()
//        
//        guard let data = snapshot.data(), let userid = data["user_id"] as? String else {
//            throw URLError(.badServerResponse)
//        }
//        let isAnonymous = data["is_anonymous"] as? Bool
//        let dateCreated = data["date_created"] as? Date
//        let email = data["email"] as? String
//        let photoUrl = data["photo_url"] as? String
//        let name = data["name"] as? String
//        
//        return DBUser(userId: userid, isAnonymous: isAnonymous, dateCreated: dateCreated, email: email, photoUrl: photoUrl, name: name)
//    }
    
//    func updateUserPremiumStatus(user: DBUser) throws {
//        try userDocument(userid: user.userId).setData(from: user, merge: true)
//    }
    
    func updateUserPremiumStatus(isPremium: Bool, userId: String) async throws {
        let data: [String : Any] = [
            DBUser.CodingKeys.isPremium.rawValue : isPremium
        ]
        try await userDocument(userid: userId).updateData(data)
    }
    
}
