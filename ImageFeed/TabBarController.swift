//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Andrey Gordienko on 23.03.2024.
//

import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = .ypBlack
        self.tabBar.tintColor = .ypWhite
        self.tabBar.standardAppearance = appearance
        
        let imagesListViewController = ImagesListViewController()
        let imagesListService = ImagesListService.shared
        let imagesListPresenter = ImagesListPresenter(imagesListService: imagesListService)
        imagesListViewController.presenter = imagesListPresenter
        imagesListPresenter.view = imagesListViewController
        imagesListViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_editorial_active"),
            selectedImage: nil)
        
        let profileViewController = ProfileViewController()
        let profilePresenter = ProfilePresenter()
        profileViewController.presenter = profilePresenter
        profilePresenter.view = profileViewController
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named: "tab_profile_active"),
            selectedImage: nil)
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
