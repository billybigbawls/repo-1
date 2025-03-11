//
//  StorageProvider.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/28/24.
//

import Foundation

protocol StorageProvider {
    func save<T: Encodable>(_ object: T, forKey key: StorageKey)
    func load<T: Decodable>(_ type: T.Type, forKey key: StorageKey) -> T?
    func delete(forKey key: StorageKey)
    func exists(forKey key: StorageKey) -> Bool
}

enum StorageKey: String {
    // User related
    case user
    case settings
    case aiLocks
    
    // Chat related
    case messages
    case squads
    case ai
    
    // Custom key creation for specific AI or Squad messages
    static func messages(forAI aiID: UUID) -> StorageKey {
        .init(rawValue: "messages_ai_\(aiID.uuidString)")!
    }
    
    static func messages(forSquad squadID: UUID) -> StorageKey {
        .init(rawValue: "messages_squad_\(squadID.uuidString)")!
    }
}

// Default implementation for common storage operations
extension StorageProvider {
    func exists(forKey key: StorageKey) -> Bool {
        UserDefaults.standard.object(forKey: key.rawValue) != nil
    }
    
    func delete(forKey key: StorageKey) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
    }
}
