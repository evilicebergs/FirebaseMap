//
//  ProductsManager.swift
//  FirebaseMap
//
//  Created by Artem Golovchenko on 2024-12-12.
//

import Foundation
import FirebaseFirestore

final class ProductsManager {
    
    static let shared = ProductsManager()
    private init() { }
    
    private let productsCollection = Firestore.firestore().collection("products")
    
    private func productDocument(productid: String) -> DocumentReference {
        productsCollection.document(productid)
    }
    
    func uploadProduct(product: Product) throws {
        try productDocument(productid: String(product.id)).setData(from: product, merge: false)
    }
    
    func getProduct(by productId: String) async throws -> Product {
        try await productDocument(productid: productId).getDocument(as: Product.self)
    }
    
    private func getAllProducts() async throws -> [Product] {
        try await productsCollection.getDocuments(as: Product.self)
    }
    
    private func getAllProductsSortedByPrice(descending: Bool) async throws -> [Product] {
        return try await productsCollection.order(by: Product.CodingKeys.price.rawValue, descending: descending).getDocuments(as: Product.self)
    }
    
    private func getAllProductsForCategory(category: String) async throws -> [Product] {
        return try await productsCollection.whereField(Product.CodingKeys.category.rawValue, isEqualTo: category).getDocuments(as: Product.self)
    }
    
    private func getAllProductsByPriceAndCategory(descending: Bool, category: String) async throws -> [Product] {
        return try await productsCollection
            .whereField(Product.CodingKeys.category.rawValue, isEqualTo: category)
            .order(by: Product.CodingKeys.price.rawValue, descending: descending)
            .getDocuments(as: Product.self)
    }
    
    func getAllProducts(descending: Bool?, category: String?) async throws -> [Product] {
        if let category, let descending {
            return try await getAllProductsByPriceAndCategory(descending: descending, category: category)
        } else if let descending {
            return try await getAllProductsSortedByPrice(descending: descending)
        } else if let category {
            return try await getAllProductsForCategory(category: category)
        } else {
            return try await getAllProducts()
        }
    }
    
}

extension Query {
    
    //generic
    func getDocuments<T>(as type: T.Type) async throws -> [T] where T : Decodable {
        let snapshot = try await self.getDocuments()
        
        return try snapshot.documents.map { document in
            try document.data(as: T.self)
        }
    }
}
