//
//  ProductCelleViewBuilder.swift
//  FirebaseMap
//
//  Created by Artem Golovchenko on 2024-12-19.
//

import SwiftUI

struct ProductCellViewBuilder: View {
    
    let productId: String
    @State private var product: Product? = nil
    
    var body: some View {
        ZStack {
            if let product {
                ProductsCellView(product: product)
            }
        }
        .task {
            self.product = try? await ProductsManager.shared.getProduct(by: productId)
        }
    }
}

#Preview {
    ProductCellViewBuilder(productId: "1")
}
