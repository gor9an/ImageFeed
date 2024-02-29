//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Andrey Gordienko on 24.02.2024.
//

import Foundation

fileprivate let UnsplashUrl = "https://unsplash.com/oauth/token"



final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() { }
    
    func makeOAuthTokenRequest(code: String) -> URLRequest {
        guard var urlComponents = URLComponents(string: UnsplashUrl)
        else { return URLRequest(url: URL(string: UnsplashUrl)!) }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: AccessKey),
            URLQueryItem(name: "client_secret", value: SecretKey),
            URLQueryItem(name: "redirect_uri", value: RedirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]
        guard let url = urlComponents.url
        else { return URLRequest(url: URL(string: UnsplashUrl)!) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        let request = makeOAuthTokenRequest(code: code)
        let task = URLSession.shared.data(for: request, completion: { result in
            switch result {
            case .success(let data):
                do { 
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    
                    completion(.success(response.access_token))
                } catch {
                    print(error)
                    
                    completion(.failure(error))
                    
                }
                
            case .failure(let error):
                print(error)
                
                completion(.failure(error))
            }
        })
        
        task.resume()
        
    }
}