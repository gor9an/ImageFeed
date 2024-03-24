//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Andrey Gordienko on 23.03.2024.
//

import Foundation

enum ImageListServiceError: Error {
    case invalidRequest
    case decoderError
    case taskNil
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

struct UrlsResult: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

struct PhotoResult: Decodable {
    let id: String
    let created_at: Date?
    let width: Int
    let height: Int
    let liked_by_user: Bool
    let description: String
    let urls: UrlsResult
}

final class ImagesListService {
    static let shared = ImagesListService()
    private init() { }
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    
    private func makeImageListRequest(page: Int) -> URLRequest? {
        guard var components = URLComponents(string: "\(DefaultBaseURL)") else {
            assertionFailure("Failed to create URL")
            return nil
        }
        components.path = "/photos"
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        guard let url = components.url else {
            assertionFailure("Failed to create URL")
            return nil
        }
        
        let request = URLRequest(url: url)
        
        return request
    }
    func fetchPhotosNextPage(_ completion: @escaping (Result<Photo, Error>) -> Void) {
        
        guard task != nil else {
            completion(.failure(ImageListServiceError.taskNil))
            return
        }
        
        let nextPageNumber = (lastLoadedPage ?? 0) + 1
        guard let request = makeImageListRequest(page: nextPageNumber) else {
            completion(.failure(ImageListServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request, completion: { [weak self] (result : Result<PhotoResult, Error>) in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let photoResult):
                let photo = Photo(
                    id: photoResult.id,
                    size: CGSize(width: photoResult.width, height: photoResult.height),
                    createdAt: Date(),
                    welcomeDescription: photoResult.description,
                    thumbImageURL: photoResult.urls.thumb,
                    largeImageURL: photoResult.urls.full,
                    isLiked: photoResult.liked_by_user
                )
                photos.append(photo)
                NotificationCenter.default.post(
                    name: ImagesListService.didChangeNotification,
                    object: self,
                    userInfo: ["Photo": photo])
                completion(.success(photo))
            case .failure(let error):
                print("[ImagesListService.fetchPhotosNextPage] failure - \(error)")
                completion(.failure(error))
            }
            self.task = nil
        })
        task.resume()
    }
}

