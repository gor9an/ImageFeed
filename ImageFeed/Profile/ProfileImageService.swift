//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Andrey Gordienko on 12.03.2024.
//

import Foundation
import SwiftKeychainWrapper

public protocol ProfileImageServiceProtocol {
    var avatarURL: String? { get }
    func fetchProfileImage(username: String, _ completion: @escaping (Result<String, Error>)-> Void)
}

enum ProfileImageServiceError: Error {
    case invalidRequest
    case decoderError
}

struct UserResult: Codable {
    let profile_image: [String: String]
}

final class ProfileImageService: ProfileImageServiceProtocol {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private let session = URLSession.shared
    
    private init() {}
    
    private (set) var avatarURL: String?
    private var task: URLSessionTask?
    private var lastUsername: String?
    private let urlSession = URLSession.shared
    private let oAuthToken = OAuth2TokenStorage.shared
    private let authConfiguration = AuthConfiguration.standard
    
    private func makeProfileImageRequest(username: String) -> URLRequest? {
        guard
            let token = oAuthToken.token else {
            assertionFailure("Token - nil")
            return nil
        }
        
        guard var components = URLComponents(string: "\(authConfiguration.defaultBaseURL)") else {
            assertionFailure("Failed to create URL")
            return nil
        }
        
        components.path = "/users/\(username)"

        guard let url = components.url else {
            assertionFailure("Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfileImage(username: String, _ completion: @escaping (Result<String, Error>)-> Void) {
        assert(Thread.isMainThread)
        
        guard lastUsername != username else {
            completion(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastUsername = username
        
        guard let request = makeProfileImageRequest(username: username) else {
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request, completion: { [weak self] (result: Result<UserResult, Error>) in
            
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let response):
                self.avatarURL = response.profile_image["large"]
                
                guard let avatarURL = self.avatarURL else {
                    assertionFailure("Failed to create profile image")
                    return
                }
                
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": avatarURL])
                
                completion(.success(avatarURL))
            case .failure(let error):
                print("[ProfileImageService.fetchProfileImage] failure - \(error)")
                completion(.failure(error))
            }

            self.task = nil
            self.lastUsername = nil
        })
        
        task.resume()
    }
    
    func clearAvatarURL() {
        avatarURL = nil
    }
}
