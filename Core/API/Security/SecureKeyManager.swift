//
//  SecureKeyManager.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 11/12/24.
//

import Foundation
import Security

class SecureKeyManager {
    // Singleton instance
    static let shared = SecureKeyManager()
    
    // MARK: - Key Constants
    
    private enum KeychainKey: String {
        case accessToken = "com.squad.accessToken"
        case refreshToken = "com.squad.refreshToken"
        case userId = "com.squad.userId"
    }
    
    // MARK: - Token Management
    
    /// Saves both access and refresh tokens to the keychain
    func saveTokens(accessToken: String, refreshToken: String) {
        _ = storeAccessToken(accessToken)
        _ = storeRefreshToken(refreshToken)
    }
    
    /// Stores the access token in the keychain
    @discardableResult
    func storeAccessToken(_ token: String) -> Bool {
        return KeychainHelper.save(key: KeychainKey.accessToken.rawValue, data: token.data(using: .utf8)!)
    }
    
    /// Retrieves the access token from the keychain
    func getAccessToken() -> String? {
        guard let data = KeychainHelper.load(key: KeychainKey.accessToken.rawValue) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    /// Stores the refresh token in the keychain
    @discardableResult
    func storeRefreshToken(_ token: String) -> Bool {
        return KeychainHelper.save(key: KeychainKey.refreshToken.rawValue, data: token.data(using: .utf8)!)
    }
    
    /// Retrieves the refresh token from the keychain
    func getRefreshToken() -> String? {
        guard let data = KeychainHelper.load(key: KeychainKey.refreshToken.rawValue) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    /// Stores the user ID in the keychain
    @discardableResult
    func storeUserId(_ userId: String) -> Bool {
        return KeychainHelper.save(key: KeychainKey.userId.rawValue, data: userId.data(using: .utf8)!)
    }
    
    /// Retrieves the user ID from the keychain
    func getUserId() -> String? {
        guard let data = KeychainHelper.load(key: KeychainKey.userId.rawValue) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    /// Clears all authentication tokens from the keychain
    func clearTokens() {
        _ = KeychainHelper.delete(key: KeychainKey.accessToken.rawValue)
        _ = KeychainHelper.delete(key: KeychainKey.refreshToken.rawValue)
    }
    
    /// Clears all user data from the keychain
    func clearAllUserData() {
        clearTokens()
        _ = KeychainHelper.delete(key: KeychainKey.userId.rawValue)
    }
    
    /// Check if the user is authenticated
    func isAuthenticated() -> Bool {
        return getAccessToken() != nil
    }
    
    // MARK: - Token Validation
    
    /// Checks if the access token is expired by parsing the JWT token
    func isAccessTokenExpired() -> Bool {
        guard let accessToken = getAccessToken() else {
            return true
        }
        
        return isTokenExpired(accessToken)
    }
    
    /// Checks if the refresh token is expired by parsing the JWT token
    func isRefreshTokenExpired() -> Bool {
        guard let refreshToken = getRefreshToken() else {
            return true
        }
        
        return isTokenExpired(refreshToken)
    }
    
    /// Checks if a JWT token is expired
    private func isTokenExpired(_ token: String) -> Bool {
        let components = token.components(separatedBy: ".")
        guard components.count >= 2 else {
            return true // Invalid token format
        }
        
        // Get payload part (second part of JWT)
        var payload = components[1]
        
        // Adjust the payload padding for Base64 decoding
        if payload.count % 4 != 0 {
            let paddingLength = 4 - (payload.count % 4)
            payload = payload.padding(toLength: payload.count + paddingLength, withPad: "=", startingAt: 0)
        }
        
        // Decode the Base64URL encoded payload
        guard let data = Data(base64Encoded: payload) else {
            return true // Invalid base64 encoding
        }
        
        do {
            // Parse the JWT payload
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let expTimestamp = json["exp"] as? TimeInterval {
                // Compare expiration with current time
                let expirationDate = Date(timeIntervalSince1970: expTimestamp)
                return expirationDate <= Date()
            } else {
                return true // Couldn't read expiration
            }
        } catch {
            return true // JSON parsing error
        }
    }
}

// MARK: - Keychain Helper

private class KeychainHelper {
    
    // MARK: - CRUD Operations
    
    /// Saves data to the keychain
    static func save(key: String, data: Data) -> Bool {
        // Delete any existing item before saving
        _ = self.delete(key: key)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    /// Loads data from the keychain
    static func load(key: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess {
            return result as? Data
        }
        return nil
    }
    
    /// Updates data in the keychain
    static func update(key: String, data: Data) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let attributesToUpdate: [String: Any] = [
            kSecValueData as String: data
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        return status == errSecSuccess
    }
    
    /// Deletes data from the keychain
    static func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
