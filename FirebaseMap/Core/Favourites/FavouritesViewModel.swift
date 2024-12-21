//
//  FavouritesViewModel.swift
//  FirebaseMap
//
//  Created by Artem Golovchenko on 2024-12-21.
//

import Foundation
import Combine

@MainActor
final class FavouritesViewModel: ObservableObject {
    
    @Published private(set) var products: [FavouriteItem] = []
    private var cancellables = Set<AnyCancellable>()
    
    func addListener() {
        guard let authUser = try? AuthenticationManager.shared.getAuthenticatedUser() else { return }
//            UserManager.shared.addListenerForUserFavouriteProduct(userId: authUser.uid) { [weak self] products in
//                self?.products = products
//            }
        UserManager.shared.addListenerForUserFavouriteProduct(userId: authUser.uid)
            .sink { completion in
                
            } receiveValue: { [weak self] products in
                self?.products = products
            }
            .store(in: &cancellables)

        }
    
//    func getFavourites() {
//        Task {
//            do {
//                let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
//                self.products = try await UserManager.shared.getFavourites(userId: authUser.uid)
//            } catch {
//                print("ERROR -- \(error)")
//            }
//        }
//    }
    
    func deleteFavourite(for productId: String) {
        Task {
            do {
                let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
                try await UserManager.shared.removeUserFavouriteProduct(userId: authUser.uid, favouriteProductId: productId)
            } catch {
                print("Error while deleting: \(error)")
            }
        }
    }
    
}
