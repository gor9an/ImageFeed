//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Andrey Gordienko on 16.02.2024.
//

import UIKit

final class AuthViewController: UIViewController {
    
    private var imageView: UIImageView?
    private let showWebView = "ShowWebView"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    
    private func configureView() {
        imageView = UIImageView(image: UIImage(named: "Logo_of_Unsplash"))
        let loginButton = UIButton()
        loginButton.addTarget(self, action: #selector(Self.didTapLoginButton), for: .touchUpInside)
        
        guard let imageView else {
            return
        }
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        view.addSubview(loginButton)
        view.backgroundColor = .ypBlack
        
        loginButton.setTitle("Войти", for: .normal)
        loginButton.setTitleColor(.ypBlack, for: .normal)
        loginButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        loginButton.backgroundColor = .ypWhite
        loginButton.layer.cornerRadius = 16
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebView {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else { fatalError("Failed to prepare for \(showWebView)") }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
        
    }
    
    @objc
    private func didTapLoginButton() {
        performSegue(withIdentifier: showWebView, sender: nil)
    }
}

//    MARK: - WebViewViewControllerDelegate
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}
