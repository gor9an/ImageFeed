//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Andrey Gordienko on 10.03.2024.
//

import Foundation

enum ProfileServiceError: Error {
    case invalidRequest
}

struct ProfileResult: Decodable {
    let username: String
    let first_name: String?
    let last_name: String?
    let bio: String?
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String
}

final class ProfileService {
    static let shared = ProfileService()
    private init() { }
    
    private(set) var profile: Profile?
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastToken: String?
    
    func makeProfileInfoRequest(token: String) -> URLRequest? {
        guard var components = URLComponents(string: "\(DefaultBaseURL)") else {
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
        
        let task = urlSession.data(for: request, completion: { [weak self] result in            
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(ProfileResult.self, from: data)
                    
                    self?.profile = Profile(
                        username: response.username,
                        name: "\(response.first_name ?? "") \(response.last_name ?? "")",
                        loginName: "@\(response.username)",
                        bio: response.bio ?? "")
                    
                    guard let profile = self?.profile else {
                        assertionFailure("Failed to create profile")
                        return
                    }
                    
                    completion(.success(profile))
                } catch {
                    completion(.failure(error))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
            
            self?.task = nil
            self?.lastToken = nil
        })
        task.resume()
    }
}
