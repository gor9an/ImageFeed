//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Andrey Gordienko on 31.03.2024.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private let authConfiguration = AuthConfiguration.standard
    private init() {}
    
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: authConfiguration.keyChainKey)
        }
        set {
            guard let newValue else {
                return
            }
            KeychainWrapper.standard.set(newValue, forKey: authConfiguration.keyChainKey)
        }
    }
}
