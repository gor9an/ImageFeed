//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Andrey Gordienko on 05.01.2024.
//

import Kingfisher
import UIKit

final class ImagesListCell: UITableViewCell {
    //MARK: - IBOutlets
    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet private weak var dateTitle: UILabel!
    @IBOutlet private weak var likeButton: UIButton!
    static let  reuseIdentifier = "ImagesListCell"
}

//MARK: - ImagesListCell extension
extension ImagesListCell {
    override func prepareForReuse() {
        super.prepareForReuse()
        cardImage.kf.cancelDownloadTask()
    }
    func configCell(date: String, isLiked: Bool) {
        self.selectionStyle = .none
        
        cardImage.layer.cornerRadius = 16
        cardImage.layer.masksToBounds = true

        dateTitle.text = date
        
        let likeImage = isLiked ? UIImage(named: "FavoritesActive") : UIImage(named: "FavoritesNoActive")
        likeButton.imageView?.image = likeImage
    }
}
