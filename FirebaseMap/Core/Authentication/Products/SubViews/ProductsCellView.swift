//
//  ProductsCellView.swift
//  FirebaseMap
//
//  Created by Artem Golovchenko on 2024-12-12.
//

import SwiftUI

struct ProductsCellView: View {
    
    let product: Product
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            
            AsyncImage(url: URL(string: product.thumbnail ?? "")) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(height: 75)
                    .shadow(color: .black.opacity(0.3), radius: 4)
                    .clipShape(.rect(cornerRadius: 15))
            } placeholder: {
                ProgressView()
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(product.title ?? "n/a")
                    .font(.headline)
                
                Text(product.category?.capitalized ?? "n/a")
                    .padding(.horizontal)
                    .padding(.vertical, 2)
                    .background(.yellow)
                    .clipShape(.rect(cornerRadius: 15))
                
                Text("Brand: " + (product.brand ?? "n/a"))

                Text("$" + String(product.price ?? 0.0))
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text(String(product.rating ?? 0.0))
                        .padding(.leading, -3)
                }
                .padding(.top, 3)
            }
            .font(.callout)
            
        }
    }
}

#Preview {
    ProductsCellView(product: Product(id: 1, title: "t", description: "r", price: 0.2, discountPercentage: 1.9, rating: 1.8, stock: 3, brand: "Apple", category: "Test", thumbnail: "", images: [""]))
}
