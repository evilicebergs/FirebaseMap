//
//  UserManager.swift
//  FirebaseMap
//
//  Created by Artem Golovchenko on 2024-12-09.
//

import Foundation
import FirebaseFirestore

struct DBUser {
    let userid: String
    let isAnonymous: Bool?
    let dateCreated: Date?
    let email: String?
    let photoUrl: String?
    let name: String?
}

final class UserManager {
    
    static let shared = UserManager()
    private init() { }
    
    func createNewUser(auth: AuthDataResultModel) async throws {
        var userData: [String : Any] = [
            "user_id" : auth.uid,
            "is_anonymous" : auth.isAnonymous,
            "date_created" : Timestamp(),
        ]
        if let email = auth.email {
            userData["email"] = email
        }
        if let name = auth.name {
            userData["name"] = name
        }
        if let photoUrl = auth.photoUrl {
            userData["photo_url"] = photoUrl
        }
        try await Firestore.firestore().collection("users").document(auth.uid).setData(userData, merge: false)
    }
    
    func getUser(by userid: String) async throws -> DBUser {
        
        let snapshot = try await Firestore.firestore().collection("users").document(userid).getDocument()
        
        guard let data = snapshot.data(), let userid = data["user_id"] as? String else {
            throw URLError(.badServerResponse)
        }
        let isAnonymous = data["is_anonymous"] as? Bool
        let dateCreated = data["date_created"] as? Date
        let email = data["email"] as? String
        let photoUrl = data["photo_url"] as? String
        let name = data["name"] as? String
        
        return DBUser(userid: userid, isAnonymous: isAnonymous, dateCreated: dateCreated, email: email, photoUrl: photoUrl, name: name)
    }
    
}
