//
//  StorageService.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import Foundation
import UIKit

class StorageService {
    private let defaults = UserDefaults.standard
    private let fileManager = FileManager.default
    
    enum StorageKey: String {
        case user
        case messages
        case squadsKey
        case settings
        case aiLocks
    }
    
    func save<T: Encodable>(_ object: T, forKey key: StorageKey) {
        do {
            let data = try JSONEncoder().encode(object)
            defaults.set(data, forKey: key.rawValue)
        } catch {
            print("Error saving data: \(error)")
        }
    }
    
    func load<T: Decodable>(_ type: T.Type, forKey key: StorageKey) -> T? {
        guard let data = defaults.data(forKey: key.rawValue) else { return nil }
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            print("Error loading data: \(error)")
            return nil
        }
    }
    
    func saveImage(_ image: UIImage, withName name: String) -> URL? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let filename = getDocumentsDirectory().appendingPathComponent(name)
        
        do {
            try data.write(to: filename)
            return filename
        } catch {
            print("Error saving image: \(error)")
            return nil
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
