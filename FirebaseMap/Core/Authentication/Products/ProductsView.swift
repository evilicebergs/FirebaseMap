//
//  ProductsView.swift
//  FirebaseMap
//
//  Created by Artem Golovchenko on 2024-12-12.
//

import SwiftUI

@MainActor
final class ProductsViewModel: ObservableObject {
    
    @Published private(set) var products: [Product] = []
    
    func getAllProducts() async throws {
        products = try await ProductsManager.shared.getAllProducts()
    }

}

struct ProductsView: View {
    
    @StateObject private var vm = ProductsViewModel()
    
    var body: some View {
        ZStack {
            List {
                ForEach(vm.products) { product in
                    ProductsCellView(product: product)
                }
            }
        }
        .navigationTitle("Products")
        .task {
            try? await vm.getAllProducts()
        }
        
    }
}

#Preview {
    NavigationStack {
        ProductsView()
    }
}
