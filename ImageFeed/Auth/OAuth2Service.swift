//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Andrey Gordienko on 24.02.2024.
//

import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() { }
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    private let authConfiguration = AuthConfiguration.standard
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: authConfiguration.getTokenUrl) else {
            assertionFailure("Failed to create URL")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: authConfiguration.accessKey),
            URLQueryItem(name: "client_secret", value: authConfiguration.secretKey),
            URLQueryItem(name: "redirect_uri", value: authConfiguration.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]
        
        guard let url = urlComponents.url else {
            assertionFailure("Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String,Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request, completion: { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            switch result {
            case .success(let response):
                completion(.success(response.access_token))
            case .failure(let error):
                print("[OAuth2Service.fetchOAuthToken] failure - \(error)")
                completion(.failure(error))
            }
            self?.task = nil
            self?.lastCode = nil
        })
        task.resume()
    }
}
