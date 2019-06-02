//
//  PersistenceService.swift
//  TheMessagesApp
//
//  Created by Vince G on 6/1/19.
//

import Foundation

enum PersistenceKey: String {
    case currentUserId
}

protocol PersistenceService {
    func get(_ key: PersistenceKey) -> Any?
    func set(_ key: PersistenceKey, value: Any?)
}

class DefaultPersistenceService:  PersistenceService {
    static let shared = DefaultPersistenceService()
    let defaults = UserDefaults.standard
    
    func get(_ key: PersistenceKey) -> Any? {
        return defaults.value(forKey: key.rawValue)
    }
    
    func set(_ key: PersistenceKey, value: Any?) {
        defaults.set(value, forKey: key.rawValue)
    }
    
    private init() {}
}
