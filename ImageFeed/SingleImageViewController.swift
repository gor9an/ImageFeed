//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Andrey Gordienko on 31.01.2024.
//

import UIKit

final class SingleImageViewController: UIViewController {
    //MARK: - Public Properties
    var image: UIImage! {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
        }
    }
    
    //MARK: - IBOutlets
    @IBOutlet private weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
