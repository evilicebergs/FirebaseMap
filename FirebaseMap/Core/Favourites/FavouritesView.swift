//
//  FavouritesView.swift
//  FirebaseMap
//
//  Created by Artem Golovchenko on 2024-12-17.
//

import SwiftUI

struct FavouritesView: View {
    
    @StateObject private var vm = FavouritesViewModel()
    
    @Binding var selectedTab: Int
    
    var body: some View {
        if vm.products.isEmpty {
            VStack {
                Spacer()
                Text("Add products to favourites to see them here")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                Image(systemName: "folder.badge.plus")
                    .font(.largeTitle)
                    .imageScale(.large)
                    .padding(.bottom)
                Button {
                    selectedTab = 0
                } label: {
                    RoundedRectangle(cornerRadius: 10).stroke(.blue, lineWidth: 3)
                        .frame(width: 180, height: 55)
                        .overlay {
                            Text("Go To Products")
                                .padding()
                        }
                }
                Spacer()
            }
        }
        List {
            if !vm.products.isEmpty {
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
        }
        .navigationTitle("Favourites")
        .onFirstAppear {
            vm.addListener()
        }
    }
}

#Preview {
    NavigationStack {
        FavouritesView(selectedTab: .constant(1))
    }
}

