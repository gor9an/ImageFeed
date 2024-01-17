//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Andrey Gordienko on 05.01.2024.
//

import UIKit
final class ImagesListCell: UITableViewCell {
    
    //MARK: - IBOutlets
    @IBOutlet private weak var cardImage: UIImageView!
    @IBOutlet private weak var dateTitle: UILabel!
    @IBOutlet private weak var likeButton: UIButton!
    static let  reuseIdentifier = "ImagesListCell"
    
    //MARK: - Private Properties
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ru_RUS")
        return formatter
    }()
    
    //MARK: - Public Function
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath, with photosName: [String]) {
        cell.cardImage.layer.cornerRadius = 16
        cell.cardImage.layer.masksToBounds = true
        
        guard let cardImage = UIImage(named: photosName[indexPath.row]) else {
            return
        }
        
        cell.cardImage.image = cardImage
        cell.dateTitle.text = dateFormatter.string(from: Date())
        
        let likeImage = indexPath.row % 2 == 0 ? UIImage(named: "FavoritesActive") : UIImage(named: "FavoritesNoActive")
        cell.likeButton.imageView?.image = likeImage
        
        cell.selectionStyle = .none
    }
    
    
}
