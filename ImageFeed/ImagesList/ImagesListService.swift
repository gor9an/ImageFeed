//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Andrey Gordienko on 23.03.2024.
//

import Foundation
import SwiftKeychainWrapper

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
    let created_at: String
    let width: Int
    let height: Int
    let liked_by_user: Bool
    let description: String?
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
    
//    MARK: - Private functions
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
        
        guard let token = KeychainWrapper.standard.string(forKey: keyChainKey) else {
            assertionFailure("Failed to get token from storage")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    //    MARK: - Public functions
    func fetchPhotosNextPage() {
        
        guard task == nil else {
            assertionFailure("\(ImageListServiceError.taskNil)")
            return
        }
        
        let nextPageNumber = (lastLoadedPage ?? 0) + 1
        guard let request = makeImageListRequest(page: nextPageNumber) else {
            assertionFailure("\(ImageListServiceError.invalidRequest)")
            return
        }
        
        let task = urlSession.objectTask(for: request, completion: { [weak self] (result : Result<[PhotoResult], Error>) in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let photosResult):
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {
                        return
                    }
                    
                    for photoResult in photosResult {
                        let photo = Photo(
                            id: photoResult.id,
                            size: CGSize(width: photoResult.width, height: photoResult.height),
                            createdAt: Date(),
                            welcomeDescription: photoResult.description,
                            thumbImageURL: photoResult.urls.thumb,
                            largeImageURL: photoResult.urls.full,
                            isLiked: photoResult.liked_by_user
                        )
                        self.lastLoadedPage = nextPageNumber
                        self.photos.append(photo)
                    }
                    
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self,
                        userInfo: ["Photo": self.photos])
                }
            case .failure(let error):
                print("[ImagesListService.fetchPhotosNextPage] failure - \(error)")
            }
            self.task = nil
        })
        task.resume()
    }
}

