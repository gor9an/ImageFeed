//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Andrey Gordienko on 29.02.2024.
//

import UIKit
import SwiftKeychainWrapper

final class SplashViewController: UIViewController {
    private let showAuth = "ShowAuth"
    private let profileService = ProfileService.shared
    private let profileImage = ProfileImageService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        if let _ = KeychainWrapper.standard.string(forKey: keyChainKey) {
            guard let token = KeychainWrapper.standard.string(forKey: keyChainKey) else {
                assertionFailure("Failed to get token from storage")
                return
            }
            
            fetchProfile(token)
        } else {
            performSegue(withIdentifier: showAuth, sender: nil)
            
        }
    }
    
    private func configureView() {
        view.backgroundColor = .ypBlack
        let imageView = UIImageView(image: UIImage(named: "LaunchScreen"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
        ])
    }
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(identifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token, completion: ({ [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self = self else { return }
            
            switch result {
            case .success(let profile):
                self.fetchProfileImage(profile.username)
                self.switchToTabBarController()
            case .failure(let error):
                print(error)
            }
        }))
    }
    
    private func fetchProfileImage(_ username: String) {
        profileImage.fetchProfileImage(username: username, { result in            
            switch result {
            case .success(_): break
            case .failure(let error):
                print(error)
            }
            
        })
    }
}
//MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        guard let token = KeychainWrapper.standard.string(forKey: keyChainKey) else {
            assertionFailure("Failed to get token from storage")
            return
        }
        fetchProfile(token)
    }
    
    
}

//MARK: - prepare segue
extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuth {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(showAuth)")
                return
            }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}
