//
//  ViewController.swift
//  ImageFeed
//
//  Created by Andrey Gordienko on 21.12.2023.
//
import Kingfisher
import UIKit

final class ImagesListViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet private weak var tableView: UITableView!
    
    //MARK: - Private Properties
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RUS")
        return formatter
    }()
    
    private var photos: [Photo] = []
    private let showSingleImage = "ShowSingleImage"
    private let imagesListService = ImagesListService.shared
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == showSingleImage,
              let viewController = segue.destination as? SingleImageViewController,
              let indexPath = sender as? IndexPath else {
            super.prepare(for: segue, sender: sender)
            return
        }
        
        guard let imageListCell = tableView.cellForRow(at: indexPath) as? ImagesListCell else {
            return
        }
        
        let image = imageListCell.cardImage.image
        viewController.image = image
    }
    
    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
        addObserver()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addObserver()
    }
    
    deinit {
        removeObserver()
    }
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagesListService.fetchPhotosNextPage()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.register(UINib(nibName: "ImagesListCell", bundle: nil), forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
    }
    
    //MARK: - Private functions
    private func addObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTableViewAnimated(notification:)),
            name: ImagesListService.didChangeNotification,
            object: nil)
    }
    
    private func removeObserver() {
        NotificationCenter.default.removeObserver(
            self,
            name: ImagesListService.didChangeNotification,
            object: nil)
    }
    
    @objc
    private func updateTableViewAnimated(notification: Notification) {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        if oldCount != newCount {
            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                tableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
}

//MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView, 
        didSelectRowAt indexPath: IndexPath
    ) {
        performSegue(withIdentifier: showSingleImage, sender: indexPath)
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = photos[indexPath.row].size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = photos[indexPath.row].size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        guard indexPath.row + 1 == photos.count else { return }
        imagesListService.fetchPhotosNextPage()
    }
}

//MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return photos.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        let url = URL(string: photos[indexPath.row].thumbImageURL)
        let date = dateFormatter.string(from: photos[indexPath.row].createdAt ?? Date())
        let isLiked = photos[indexPath.row].isLiked
        
        imageListCell.cardImage.kf.indicatorType = .activity
        imageListCell.cardImage.kf.setImage(
            with: url,
            placeholder: UIImage(named: "images_stub")
        ) { _ in
            tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: 0)],
                                 with: .automatic)
        }
        
        imageListCell.configCell(date: date, isLiked: isLiked)
        
        return imageListCell
    }
}
