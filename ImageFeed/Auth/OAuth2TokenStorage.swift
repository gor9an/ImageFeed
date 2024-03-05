//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Andrey Gordienko on 26.02.2024.
//

import Foundation

final class OAuth2TokenStorage {
    let bearerToken = "Bearer Token"
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: bearerToken)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: bearerToken)
        }
    }
}
