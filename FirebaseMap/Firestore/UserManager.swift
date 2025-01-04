//
//  UserManager.swift
//  FirebaseMap
//
//  Created by Artem Golovchenko on 2024-12-09.
//

import Foundation
import FirebaseFirestore
import Combine


struct Movie: Codable {
    let id: String
    let title: String
    let isPopular: Bool
}

struct FavouriteItem: Codable, Identifiable {
    let id: String
    let dateCreated: Date
    let productId: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case dateCreated = "date_created"
        case productId = "product_id"
    }
}

struct DBUser: Codable {
    let userId: String
    let isAnonymous: Bool?
    let dateCreated: Date?
    let email: String?
    let photoUrl: String?
    let name: String?
    let isPremium: Bool?
    let preferences: [String]?
    let favouriteMovie: Movie?
    let profileImagePath: String?
    let profileImageUrl: String?
    
    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.email = auth.email
        self.dateCreated = Date()
        self.isAnonymous = auth.isAnonymous
        self.photoUrl = auth.photoUrl
        self.name = auth.name
        self.isPremium = false
        self.preferences = nil
        self.favouriteMovie = nil
        self.profileImagePath = nil
        self.profileImageUrl = nil
    }
    
    init(userId: String, isAnonymous: Bool? = nil, dateCreated: Date? = nil, email: String? = nil, photoUrl: String? = nil, name: String? = nil, isPremium: Bool? = nil, preferences: [String]? = nil, favouriteMovie: Movie? = nil, profileImagePath: String? = nil, profileImageUrl: String? = nil) {
        self.userId = userId
        self.isAnonymous = isAnonymous
        self.dateCreated = dateCreated
        self.email = email
        self.photoUrl = photoUrl
        self.name = name
        self.isPremium = isPremium
        self.preferences = preferences
        self.favouriteMovie = favouriteMovie
        self.profileImagePath = profileImagePath
        self.profileImageUrl = profileImageUrl
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
        case preferences = "preferences"
        case favouriteMovie = "favourite_movie"
        case profileImagePath = "profile_image_path"
        case profileImageUrl = "profile_image_url"
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
        self.preferences = try container.decodeIfPresent([String].self, forKey: .preferences)
        self.favouriteMovie = try container.decodeIfPresent(Movie.self, forKey: .favouriteMovie)
        self.profileImagePath = try container.decodeIfPresent(String.self, forKey: .profileImagePath)
        self.profileImageUrl = try container.decodeIfPresent(String.self, forKey: .profileImageUrl)
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
        try container.encodeIfPresent(self.preferences, forKey: .preferences)
        try container.encodeIfPresent(self.favouriteMovie, forKey: .favouriteMovie)
        try container.encodeIfPresent(self.profileImagePath, forKey: .profileImagePath)
        try container.encodeIfPresent(self.profileImageUrl, forKey: .profileImageUrl)
    }
    
}

final class UserManager {
    
    static let shared = UserManager()
    private init() { }
    
    private let userCollection = Firestore.firestore().collection("users")
    
    private func userDocument(userid: String) -> DocumentReference {
        userCollection.document(userid)
    }
    
    private func userFavouriteCollection(userId: String) -> CollectionReference {
        userDocument(userid: userId).collection("favourite_products")
    }
    
    private func userFavouriteProductDocument(userid: String, favouriteProductId: String) -> DocumentReference {
        userFavouriteCollection(userId: userid).document(favouriteProductId)
    }
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        //encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    private var userFavouriteListener: ListenerRegistration? = nil
    
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        //decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    func createNewUser(user: DBUser) async throws {
        try userDocument(userid: user.userId).setData(from: user, merge: true)
    }
    
    func userExists(userId: String) async throws -> Bool {
        try await userDocument(userid: userId).getDocument().exists
    }
    
    func deleteUser(userId: String) async throws {
        try await userDocument(userid: userId).delete()
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
    
    func updateUserProfileImage(userId: String, url: String?, path: String?) async throws {
        let data: [String : Any] = [
            DBUser.CodingKeys.profileImagePath.rawValue : path as Any,
            DBUser.CodingKeys.profileImageUrl.rawValue : url as Any
        ]
        try await userDocument(userid: userId).updateData(data)
    }
    
    func addUserPreference(userId: String, preference: String) async throws {
        let data: [String : Any] = [
            DBUser.CodingKeys.preferences.rawValue : FieldValue.arrayUnion([preference])
        ]
        try await userDocument(userid: userId).updateData(data)
    }
    
    func removeUserPreference(userId: String, preference: String) async throws {
        let data: [String : Any] = [
            DBUser.CodingKeys.preferences.rawValue : FieldValue.arrayRemove([preference])
        ]
        try await userDocument(userid: userId).updateData(data)
    }
    
    func addFavouriteMovie(userId: String, movie: Movie) async throws {
        guard let data = try? encoder.encode(movie) else {
            throw URLError(.badURL)
        }
        let dict: [String : Any] = [
            DBUser.CodingKeys.favouriteMovie.rawValue : data
        ]
        try await userDocument(userid: userId).updateData(dict)
    }
    
    func removeFavouriteMovie(userId: String) async throws {
        let data: [String : Any?] = [
            DBUser.CodingKeys.preferences.rawValue : nil
        ]
        try await userDocument(userid: userId).updateData(data as [AnyHashable : Any])
    }
    
    func addUserFavouriteProduct(userId: String, productId: Int) async throws {
        
        let document = userFavouriteCollection(userId: userId).document()
        let documentId = document.documentID
        
        let data: [String : Any] = [
            "id" : documentId,
            "product_id" : productId,
            "date_created" : Timestamp()
        ]
        
        try await document.setData(data, merge: false)
    }
    
    func removeUserFavouriteProduct(userId: String, favouriteProductId: String) async throws {
        
        try await userFavouriteProductDocument(userid: userId, favouriteProductId: favouriteProductId).delete()
    }
    
    func getFavourites(userId: String) async throws -> [FavouriteItem] {
        let products = try await userFavouriteCollection(userId: userId).getDocuments(as: FavouriteItem.self)
        
        return products
    }
    
    //this is how to disable listener
    func removeListenerForFavourites() {
        self.userFavouriteListener?.remove()
    }
    
    func addListenerForUserFavouriteProduct(userId: String, completion: @escaping (_ products: [FavouriteItem]) -> Void) {
        self.userFavouriteListener = userFavouriteCollection(userId: userId).addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("No Documents")
                return
            }
            
            let products: [FavouriteItem] = documents.compactMap({ try? $0.data(as: FavouriteItem.self) })
            
            completion(products)
            
            //add specific actions to some items
            querySnapshot?.documentChanges.forEach({ diff in
                if diff.type == .added {
                    print("New Item: \(diff.document.data())")
                }
                if diff.type == .modified {
                    print("Modified Item: \(diff.document.data())")
                }
                if diff.type == .removed {
                    print("Deleted Item: \(diff.document.data())")
                }
            })
            
        }
    }
    
//    func addListenerForUserFavouriteProduct(userId: String) -> AnyPublisher<[FavouriteItem], any Error> {
//        let publisher = PassthroughSubject<[FavouriteItem], Error>()
//        
//        self.userFavouriteListener = userFavouriteCollection(userId: userId).addSnapshotListener { querySnapshot, error in
//            guard let documents = querySnapshot?.documents else {
//                print("No Documents")
//                return
//            }
//            
//            let products: [FavouriteItem] = documents.compactMap({ try? $0.data(as: FavouriteItem.self) })
//            
//            publisher.send(products)
//        }
//        
//        return publisher.eraseToAnyPublisher()
//    }
    
    func addListenerForUserFavouriteProduct(userId: String) -> AnyPublisher<[FavouriteItem], any Error> {
        let (publisher, listner) = userFavouriteCollection(userId: userId).addSnapshotListener(as: FavouriteItem.self)
        self.userFavouriteListener = listner
        
        return publisher
    }
    
}
