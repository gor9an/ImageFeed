//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Andrey Gordienko on 10.03.2024.
//

import Foundation

public protocol ProfileServiceProtocol {
    var profile: Profile? { get }
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void)
}

enum ProfileServiceError: Error {
    case invalidRequest
}

struct ProfileResult: Decodable {
    let username: String
    let first_name: String?
    let last_name: String?
    let bio: String?
}

public struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String
}

final class ProfileService: ProfileServiceProtocol {
    static let shared = ProfileService()
    private init() { }
    
    private(set) var profile: Profile?
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastToken: String?
    private let session = URLSession.shared
    private let authConfiguration = AuthConfiguration.standard
    
    func makeProfileInfoRequest(token: String) -> URLRequest? {
        guard var components = URLComponents(string: "\(authConfiguration.defaultBaseURL)") else {
            assertionFailure("Failed to create URL")
            return nil
        }
        components.path = "/me"
        
        guard let url = components.url else {
            assertionFailure("Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastToken != token else {
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastToken = token
        
        guard let request = makeProfileInfoRequest(token: token) else {
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        let task = session.objectTask(for: request, completion: { [weak self] (result: Result<ProfileResult, Error>) in
            switch result {
            case .success(let profile):
                self?.profile = Profile(
                    username: profile.username,
                    name: "\(profile.first_name ?? "") \(profile.last_name ?? "")",
                    loginName: "@\(profile.username)",
                    bio: profile.bio ?? "")
                
                guard let profile = self?.profile else {
                    assertionFailure("Failed to create profile")
                    return
                }
                completion(.success(profile))
                
            case .failure(let error):
                print("[ProfileService.fetchProfile] failure - \(error)")
                completion(.failure(error))
            }
            
            self?.task = nil
            self?.lastToken = nil
        })
        
        task.resume()
    }
    
    func cleanProfile() {
        profile = nil
    }
}
