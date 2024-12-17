//
//  FavouritesView.swift
//  FirebaseMap
//
//  Created by Artem Golovchenko on 2024-12-17.
//

import SwiftUI

@MainActor
final class FavouritesViewModel: ObservableObject {
    
    @Published private(set) var products: [Product] = []
    
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
    
}

struct FavouritesView: View {
    
    @StateObject private var vm = FavouritesViewModel()
    
    var body: some View {
        List {
            ForEach(vm.products) { product in
                ProductsCellView(product: product)
                
                
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
