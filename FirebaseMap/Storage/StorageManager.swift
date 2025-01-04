//
//  StorageManager.swift
//  FirebaseMap
//
//  Created by Artem Golovchenko on 2025-01-03.
//

import Foundation
import FirebaseStorage
import UIKit

final class StorageManager {
    
    static let shared = StorageManager()
    
    private init() { }
    
    private let storage = Storage.storage().reference()
    
    private var imagesReference: StorageReference {
        storage.child("images")
    }
    
    private func userReference(userId: String) -> StorageReference {
        storage.child("users").child(userId)
    }
    
    func getPath(path: String) -> StorageReference {
        Storage.storage().reference(withPath: path)
    }
    
    func getUrlForImage(path: String) async throws -> URL {
        return try await getPath(path: path).downloadURL()
    }
    
    func saveImage(data: Data, userId: String) async throws -> (path: String, name: String) {
        
        let meta = StorageMetadata()
        meta.contentType = "image/jpeg"
        
        let path = "\(UUID().uuidString).jpeg"
        let returnedMetaData = try await userReference(userId: userId).child(path).putDataAsync(data, metadata: meta)
        
        guard let returnedPath = returnedMetaData.path, let name = returnedMetaData.name else {
            throw URLError(.badURL)
        }
        
        return (returnedPath, name)
    }
    
    func saveImage(image: UIImage, userId: String) async throws -> (path: String, name: String) {
        guard let data = image.jpegData(compressionQuality: 1) else {
            throw URLError(.appTransportSecurityRequiresSecureConnection)
        }
        
        return try await saveImage(data: data, userId: userId)
    }
    
    private func getData(userId: String, path: String) async throws -> Data {
        try await storage.child(path).data(maxSize: 3 * 1024 * 1024)
    }
    
    private func getImage(userId: String, path: String) async throws -> UIImage {
        let data = try await getData(userId: userId, path: path)
        
        guard let image = UIImage(data: data) else {
            throw URLError(.badURL)
        }
        
        return image
    }
    
    func deleteImage(path: String) async throws {
        try await getPath(path: path).delete()
    }
    
}
