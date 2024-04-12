//
//  ImagesListPresenter.swift
//  ImageFeed
//
//  Created by Andrey Gordienko on 12.04.2024.
//

import Foundation

public protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    func formatDate(_ date: Date) -> String
    func updateTableView()
    func didLikeButtonTapped(_ index: Int, _ cell: ImagesListCell)
    func getPhotoAtIndex(_ index: Int) -> Photo?
    func willDisplay(indexPath: IndexPath)
    func getPhotosCount() -> Int
    func viewDidLoad()
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    private var photos: [Photo] = []
    private let imagesListService: ImagesListServiceProtocol
    
    init (imagesListService: ImagesListServiceProtocol = ImagesListService.shared) {
        self.imagesListService = imagesListService
    }

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RUS")
        return formatter
    }()
    
    func viewDidLoad() {
        imagesListService.fetchPhotosNextPage()
    }
    
    func updateTableView() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            view?.updateTable(oldCount: oldCount, newCount: newCount)
        }
    }
    
    func formatDate(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }
    
    func getPhotoAtIndex(_ index: Int) -> Photo? {
        photos[index]
    }
    
    func didLikeButtonTapped(_ index: Int, _ cell: ImagesListCell) {
        guard let photo = getPhotoAtIndex(index) else { return }
        
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: photo.isLiked, { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                let photos = imagesListService.photos
                self.photos = photos
                cell.setIsLiked(isLiked: !photo.isLiked)
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                UIBlockingProgressHUD.dismiss()
                view?.showAlert(error: error)
            }
        })
    }
    
    func willDisplay(indexPath: IndexPath) {
        guard indexPath.row + 1 == photos.count else { return }
        imagesListService.fetchPhotosNextPage()
    }
    
    func getPhotosCount() -> Int {
        photos.count
    }
}
