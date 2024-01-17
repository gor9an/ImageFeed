//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Andrey Gordienko on 05.01.2024.
//

import UIKit
final class ImagesListCell: UITableViewCell {

    @IBOutlet weak var cardImage: UIImageView!
    @IBOutlet weak var dateTitle: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    static let reuseIdentifier = "ImagesListCell"
    
}
