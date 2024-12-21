//
//  Query+Ext.swift
//  FirebaseMap
//
//  Created by Artem Golovchenko on 2024-12-21.
//

import Foundation
import Combine
import FirebaseFirestore

extension Query {
    
    //generic
//    func getDocuments<T>(as type: T.Type) async throws -> [T] where T : Decodable {
//        let snapshot = try await self.getDocuments()
//
//        return try snapshot.documents.map { document in
//            try document.data(as: T.self)
//        }
//    }
    
    func getDocuments<T>(as type: T.Type) async throws -> [T] where T : Decodable {
        let (products, _) = try await getDocumentsWithSnapShot(as: type)
        
        return products
    }
    
    func getDocumentsWithSnapShot<T>(as type: T.Type) async throws -> ([T], DocumentSnapshot?) where T : Decodable {
        let snapshot = try await self.getDocuments()
        
        let products = try snapshot.documents.map { document in
            try document.data(as: T.self)
        }
        
        return (products, snapshot.documents.last)
    }
    
    func start(afterDocument lastDoc: DocumentSnapshot?) -> Query {
        guard let lastDoc else { return self }
        
        return self.start(afterDocument: lastDoc)
    }
    
    func aggregateCount() async throws -> Int {
        let snapshot = try await self.count.getAggregation(source: .server)
        return Int(truncating: snapshot.count)
    }
    
    func addSnapshotListener<T>(as type: T.Type) -> (AnyPublisher<[T], any Error>, ListenerRegistration) where T : Decodable {
        let publisher = PassthroughSubject<[T], Error>()
        
        let listener = self.addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("No Documents")
                return
            }
            
            let products: [T] = documents.compactMap({ try? $0.data(as: T.self) })
            
            publisher.send(products)
        }
        
        return (publisher.eraseToAnyPublisher(), listener)
    }
    
}
