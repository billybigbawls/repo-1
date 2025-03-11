//
//  EncryptionService.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import CryptoKit
import Foundation

class EncryptionService {
    private var key: SymmetricKey?
    
    init() {
        generateKey()
    }
    
    private func generateKey() {
        key = SymmetricKey(size: .bits256)
    }
    
    func encrypt(_ data: Data) -> Data? {
        guard let key = key else { return nil }
        do {
            let sealedBox = try AES.GCM.seal(data, using: key)
            return sealedBox.combined
        } catch {
            print("Encryption error: \(error)")
            return nil
        }
    }
    
    func decrypt(_ data: Data) -> Data? {
        guard let key = key else { return nil }
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            return try AES.GCM.open(sealedBox, using: key)
        } catch {
            print("Decryption error: \(error)")
            return nil
        }
    }
}
