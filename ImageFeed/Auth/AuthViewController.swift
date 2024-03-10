//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Andrey Gordienko on 16.02.2024.
//

import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    
    private var imageView = UIImageView(image: UIImage(named: "Logo_of_Unsplash"))
    private var loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Войти", for: .normal)
        button.setTitleColor(.ypBlack, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 17)
        button.backgroundColor = .ypWhite
        button.layer.cornerRadius = 16
        
        return button
    }()
    
    private let storage = OAuth2TokenStorage()
    weak var delegate: SplashViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    private func configureView() {
        loginButton.addTarget(self, action: #selector(Self.didTapLoginButton), for: .touchUpInside)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        view.addSubview(loginButton)
        view.backgroundColor = .ypBlack
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.heightAnchor.constraint(equalToConstant: 60),
            
            loginButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90),
            loginButton.heightAnchor.constraint(equalToConstant: 48)
            
        ])
    }
    
    @objc
    private func didTapLoginButton() {
        let vc = WebViewViewController()
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
}

//    MARK: - WebViewViewControllerDelegate
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(
        _ vc: WebViewViewController,
        didAuthenticateWithCode code: String
    ) {
        vc.dismiss(animated: true)
        
        UIBlockingProgressHUD.show()
        OAuth2Service.shared.fetchOAuthToken(code: code, completion: { [weak self] result in
            guard let self = self else { return }
            
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success(let access_token):
                print(access_token)
                self.storage.token = access_token
                delegate?.didAuthenticate(self)
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}

