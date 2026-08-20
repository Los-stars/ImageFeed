//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Amir on 29.07.2026.
//

import Foundation

final class OAuth2TokenStorage{
    static let shared = OAuth2TokenStorage()
    private init() {}
    private let storage = UserDefaults.standard
    private let tokenKey = "BearerToken"
    
    var token: String? {
        get{
            storage.string(forKey: tokenKey)
        }
        set{
            storage.set(newValue, forKey: tokenKey)
        }
    }
}
