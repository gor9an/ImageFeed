//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Andrey Gordienko on 27.03.2024.
//

import Foundation
import SwiftKeychainWrapper
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    private init() { }
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let imagesListService = ImagesListService.shared
    
    func logout() {
        cleanCookies()
        profileService.cleanProfile()
        profileImageService.clearAvatarURL()
        imagesListService.clearPhotos()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
            completionHandler: { records in
                records.forEach { record in
                    WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                }
            })
        KeychainWrapper.standard.remove(forKey: KeychainWrapper.Key(rawValue: keyChainKey))
    }
}
