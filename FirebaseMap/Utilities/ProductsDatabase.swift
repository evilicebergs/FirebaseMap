//
//  ProductsDatabase.swift
//  FirebaseMap
//
//  Created by Artem Golovchenko on 2024-12-12.
//

import Foundation

struct ProductArray: Codable {
    let products: [Product]
    let total, skip, limit: Int
}

struct Product: Identifiable, Codable {
    let id: Int
    let title: String?
    let description: String?
    let price: Double?
    let discountPercentage: Double?
    let rating: Double?
    let stock: Int?
    let brand, category: String?
    let thumbnail: String?
    let images: [String]?
    
    //    func downloadProductsAndUploadToFirebase() {
    //
    //        guard let url = URL(string: "https://dummyjson.com/products") else { return }
    //        Task {
    //            do {
    //                let (data, _) = try await URLSession.shared.data(from: url)
    //                let results = try JSONDecoder().decode(ProductArray.self, from: data)
    //
    //                let productArray = results.products
    //
    //                for product in productArray {
    //                    try ProductsManager.shared.uploadProduct(product: product)
    //                }
    //
    //                print("SUCCESS")
    //                print(results.products.count)
    //            } catch {
    //                print(error)
    //            }
    //        }
    //    }
    
}
