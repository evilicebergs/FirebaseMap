//
//  FavouritesView.swift
//  FirebaseMap
//
//  Created by Artem Golovchenko on 2024-12-17.
//

import SwiftUI

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
        .onFirstAppear {
            vm.addListener()
        }
    }
}

#Preview {
    NavigationStack {
        FavouritesView()
    }
}

