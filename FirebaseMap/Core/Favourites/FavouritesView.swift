//
//  FavouritesView.swift
//  FirebaseMap
//
//  Created by Artem Golovchenko on 2024-12-17.
//

import SwiftUI

@MainActor
final class FavouritesViewModel: ObservableObject {
    
    @Published private(set) var products: [FavouriteItem] = []
    
    func getFavourites() {
        Task {
            do {
                let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
                self.products = try await UserManager.shared.getFavourites(userId: authUser.uid)
            } catch {
                print("ERROR -- \(error)")
            }
        }
    }
    
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

struct FavouritesView: View {
    
    @StateObject private var vm = FavouritesViewModel()
    
    var body: some View {
        List {
            ForEach(vm.products) { product in
                ProductCellViewBuilder(productId: product.productId.formatted())
                    .swipeActions() {
                        Button(role: .destructive) {
                            vm.deleteFavourite(for: product.id)
                        } label: {
                            Image(systemName: "trash")
                            Text("Delete")
                        }

                    }
                
            }
        }
        .navigationTitle("Favourites")
        .onAppear {
            vm.getFavourites()
        }
    }
}

#Preview {
    NavigationStack {
        FavouritesView()
    }
}
