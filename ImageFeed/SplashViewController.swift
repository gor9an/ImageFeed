//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Andrey Gordienko on 29.02.2024.
//

import SwiftKeychainWrapper
import UIKit


final class SplashViewController: UIViewController {
    private let profileService = ProfileService.shared
    private let profileImage = ProfileImageService.shared
    private let oAuthToken = OAuth2TokenStorage.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        if let _ = oAuthToken.token {
            guard let token = oAuthToken.token else {
                assertionFailure("Failed to get token from storage")
                return
            }
            
            fetchProfile(token)
        } else {
            showAuthenticationScreen()
        }
    }
    
    private func showAuthenticationScreen() {
        let authVC = AuthViewController()
        authVC.delegate = self
        authVC.modalPresentationStyle = .overFullScreen
        present(authVC, animated: true, completion: nil)
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
        
        let tabBarController = TabBarController()
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
                showError()
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
    
    private func showError() {
        let alert = UIAlertController(
            title: "Что-то пошло не так.",
            message: "Попробовать ещё раз?",
            preferredStyle: .alert)
        let exitAction = UIAlertAction(title: "Не надо", style: .cancel)
        let retryAction = UIAlertAction(title: "Повторить", style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            guard let token = oAuthToken.token else {
                assertionFailure("Failed to get token from storage")
                return
            }
            
            self.fetchProfile(token)
        })
        alert.addAction(exitAction)
        alert.addAction(retryAction)
        present(alert, animated: true, completion: nil)
    }
}
//MARK: - AuthViewControllerDelegate
extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        guard let token = oAuthToken.token else {
            assertionFailure("Failed to get token from storage")
            return
        }
        fetchProfile(token)
    }
    
    
}
