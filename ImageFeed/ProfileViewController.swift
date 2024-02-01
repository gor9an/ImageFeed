//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Andrey Gordienko on 28.01.2024.
//

import UIKit

final class ProfileViewController: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var nickname: UILabel!
    @IBOutlet weak var descriptionOfProfile: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photo.layer.cornerRadius = 35
        // Do any additional setup after loading the view.
    }
    

    @IBAction func didTapExitButton(_ sender: Any) {
    }
}
