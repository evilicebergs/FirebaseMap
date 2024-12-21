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
    
//    private func getAllProducts() async throws -> [Product] {
//        try await productsCollection.getDocuments(as: Product.self)
//    }
//    
//    private func getAllProductsSortedByPrice(descending: Bool) async throws -> [Product] {
//        return try await productsCollection.order(by: Product.CodingKeys.price.rawValue, descending: descending).getDocuments(as: Product.self)
//    }
//    
//    private func getAllProductsForCategory(category: String) async throws -> [Product] {
//        return try await productsCollection.whereField(Product.CodingKeys.category.rawValue, isEqualTo: category).getDocuments(as: Product.self)
//    }
//    
//    private func getAllProductsByPriceAndCategory(descending: Bool, category: String) async throws -> [Product] {
//        return try await productsCollection
//            .whereField(Product.CodingKeys.category.rawValue, isEqualTo: category)
//            .order(by: Product.CodingKeys.price.rawValue, descending: descending)
//            .getDocuments(as: Product.self)
//    }
    
    private func getAllProductsQuery() -> Query {
        productsCollection
    }
    
    private func getAllProductsSortedByPriceQuery(descending: Bool) -> Query {
        return productsCollection.order(by: Product.CodingKeys.price.rawValue, descending: descending)
    }
    
    private func getAllProductsForCategoryQuery(category: String) -> Query {
        return productsCollection.whereField(Product.CodingKeys.category.rawValue, isEqualTo: category)
    }
    
    private func getAllProductsByPriceAndCategoryQuery(descending: Bool, category: String) -> Query {
        return productsCollection
            .whereField(Product.CodingKeys.category.rawValue, isEqualTo: category)
            .order(by: Product.CodingKeys.price.rawValue, descending: descending)
    }
    
    func getAllProducts(descending: Bool?, category: String?, count: Int, lastDocument: DocumentSnapshot?) async throws -> ([Product], DocumentSnapshot?) {
        
        var query: Query = getAllProductsQuery()
        
        if let category, let descending {
            query = getAllProductsByPriceAndCategoryQuery(descending: descending, category: category)
        } else if let descending {
            query = getAllProductsSortedByPriceQuery(descending: descending)
        } else if let category {
            query = getAllProductsForCategoryQuery(category: category)
        }
        
        return try await query
            .limit(to: count)
            .start(afterDocument: lastDocument)
            .getDocumentsWithSnapShot(as: Product.self)
    }
    
    func getProductsByRating(limit: Int, lastRating: Double?) async throws -> [Product] {
        try await productsCollection
            .order(by: Product.CodingKeys.rating.rawValue, descending: true)
            .limit(to: limit)
            .start(after: [lastRating ?? 999999])
            .getDocuments(as: Product.self)
    }
    
    func getProductsByRating(limit: Int, last: DocumentSnapshot?) async throws -> ([Product], DocumentSnapshot?) {
        if let last {
            return try await productsCollection
                .order(by: Product.CodingKeys.rating.rawValue, descending: true)
                .limit(to: limit)
                .start(afterDocument: last)
                .getDocumentsWithSnapShot(as: Product.self)
        } else {
            return try await productsCollection
                .order(by: Product.CodingKeys.rating.rawValue, descending: true)
                .limit(to: limit)
                .getDocumentsWithSnapShot(as: Product.self)
        }
    }
    
    func getAllProductCount() async throws -> Int {
        return try await productsCollection.aggregateCount()
    }
    
}
