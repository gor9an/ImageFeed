//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Andrey Gordienko on 27.03.2024.
//

import Foundation
import Kingfisher
import SwiftKeychainWrapper
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    private init() { }
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let imagesListService = ImagesListService.shared
    private let authConfiguration = AuthConfiguration.standard
    
    func logout() {
        cleanCookies()
        profileService.cleanProfile()
        profileImageService.clearAvatarURL()
        imagesListService.clearPhotos()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        let cache = ImageCache.default
        cache.clearMemoryCache()
        cache.clearDiskCache { print("Done") }
        WKWebsiteDataStore.default().fetchDataRecords(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
            completionHandler: { records in
                records.forEach { record in
                    WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                }
            })
        KeychainWrapper.standard.remove(forKey: KeychainWrapper.Key(rawValue: authConfiguration.keyChainKey))
    }
}
