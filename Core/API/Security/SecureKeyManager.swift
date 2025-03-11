//
//  SecureKeyManager.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 11/12/24.
//

import Foundation
import Security

class SecureKeyManager {
    static let shared = SecureKeyManager()
    
    private let keychain = KeychainAccess()
    private let serviceIdentifier = "com.squad.apikey"
    
    private init() {}
    
    func storeAPIKey(_ key: String) -> Bool {
        return keychain.store(key: key, service: serviceIdentifier)
    }
    
    func getAPIKey() -> String? {
        return keychain.retrieve(service: serviceIdentifier)
    }
    
    func removeAPIKey() -> Bool {
        return keychain.remove(service: serviceIdentifier)
    }
}

// MARK: - Keychain Access
private class KeychainAccess {
    func store(key: String, service: String) -> Bool {
        guard let data = key.data(using: .utf8) else { return false }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecValueData as String: data
        ]
        
        // First remove any existing key
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    func retrieve(service: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess,
           let retrievedData = dataTypeRef as? Data,
           let result = String(data: retrievedData, encoding: .utf8) {
            return result
        }
        return nil
    }
    
    func remove(service: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}

// MARK: - API Key Management
extension SecureKeyManager {
    func isAPIKeyStored() -> Bool {
        return getAPIKey() != nil
    }
    
    func validateAPIKey(_ key: String) -> Bool {
        // Basic validation
        return key.hasPrefix("sk-") && key.count > 20
    }
    
    @discardableResult
    func updateAPIKey(_ key: String) -> Bool {
        guard validateAPIKey(key) else { return false }
        return storeAPIKey(key)
    }
}

// MARK: - Error Handling
enum KeychainError: Error {
    case storeFailed
    case retrievalFailed
    case deleteFailed
    case invalidKey
    
    var localizedDescription: String {
        switch self {
        case .storeFailed:
            return "Failed to store API key in keychain"
        case .retrievalFailed:
            return "Failed to retrieve API key from keychain"
        case .deleteFailed:
            return "Failed to delete API key from keychain"
        case .invalidKey:
            return "Invalid API key format"
        }
    }
}
