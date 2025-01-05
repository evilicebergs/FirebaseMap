//
//  ProfileViewModel.swift
//  FirebaseMap
//
//  Created by Artem Golovchenko on 2025-01-03.
//

import Foundation
import SwiftUI
import PhotosUI

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    
    private let savePath = FileManager.documentsDirectory.appending(path: "SavedImage")
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    func togglePremiumStatus() {
        guard let user else { return }
        let currentValue = user.isPremium ?? false
        Task {
            try await UserManager.shared.updateUserPremiumStatus(isPremium: !currentValue, userId: user.userId)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func removeUserPreference(text: String) {
        guard let user else { return }
        Task {
            try await UserManager.shared.removeUserPreference(userId: user.userId, preference: text)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func addUserPreference(text: String) {
        guard let user else { return }
        Task {
            try await UserManager.shared.addUserPreference(userId: user.userId, preference: text)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func addFavouriteMovie() {
        guard let user else { return }
        let movie = Movie(id: "1", title: "Avatar 2", isPopular: true)
        Task {
            try await UserManager.shared.addFavouriteMovie(userId: user.userId, movie: movie)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func removeFavouriteMovie() {
        guard let user else { return }
        Task {
            try await UserManager.shared.removeFavouriteMovie(userId: user.userId)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func saveProfileImage(item: PhotosPickerItem) {
        Task {

            guard let data = try await item.loadTransferable(type: Data.self), let userId = user?.userId else { return }
            
            let (path, _) = try await StorageManager.shared.saveImage(data: data, userId: userId)
            let url = try await StorageManager.shared.getUrlForImage(path: path)
            try await UserManager.shared.updateUserProfileImage(userId: userId, url: url.absoluteString, path: path)
            
            print("Success! \(path)")
            
        }
    }
    
    func saveImageToFileManager(item: PhotosPickerItem) async throws {
        
        guard let data = try await item.loadTransferable(type: Data.self) else {
            throw URLError(.badServerResponse)
        }
        
        try data.write(to: savePath)
    }
    
    func loadImage() -> UIImage? {
        do {
            
            let data = try Data(contentsOf: savePath)
            
            return UIImage(data: data)
            
        } catch {
            print("No Image in the directory")
            return nil
        }
    }
    
    func displayPhoto(item: PhotosPickerItem) async throws -> UIImage? {
        guard let data = try await item.loadTransferable(type: Data.self) else {
            throw URLError(.badServerResponse)
        }
        return UIImage(data: data)
    }
 
    func deleteProfileImage() async throws {
        
        guard let user, let path = user.profileImagePath else { return }
        
        try await StorageManager.shared.deleteImage(path: path)
        try await UserManager.shared.updateUserProfileImage(userId: user.userId, url: nil, path: nil)
    }
    
}
