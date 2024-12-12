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
    
    func getAllProducts() async throws -> [Product] {
        try await productsCollection.getDocuments(as: Product.self)
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
