//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by Andrey Gordienko on 25.02.2024.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        let task = dataTask(with: request) { data, response, error in
            if let data,
               let response,
               let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200..<300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    print(String(data: data, encoding: .utf8) ?? "")
                    print(NetworkError.httpStatusCode(statusCode)) //status code out of 200...300
                    
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error {
                print(NetworkError.urlRequestError(error)) //url request error
                
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                print(NetworkError.urlSessionError) //url session error
                
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        }
        
        return task
    }
}

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping(Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let response = try decoder.decode(T.self, from: data)
                    completion(.success(response))
                } catch {
                    print("Ошибка декодирования: \(error.localizedDescription), Данные: \(String(data: data, encoding: .utf8) ?? "")")
                    
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return task
    }
}
