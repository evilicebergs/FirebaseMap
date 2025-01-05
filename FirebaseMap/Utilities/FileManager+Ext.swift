//
//  FileManager+Ext.swift
//  FirebaseMap
//
//  Created by Artem Golovchenko on 2025-01-05.
//

import Foundation

extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
