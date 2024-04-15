//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Andrey Gordienko on 28.01.2024.
//

import Kingfisher
import UIKit

public protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfilePresenterProtocol? { get set }
    var profile: Profile? { get set }
    func prepareImage(url: URL)
}

final class ProfileViewController: UIViewController,
                                   ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    //MARK: - Private Properties
    private var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        return imageView
    }()
    private var nameLabel = UILabel()
    private var nicknameLabel = UILabel()
    private var descriptionLabel = UILabel()
    private var stackView = UIStackView()
    private let profileLogoutService = ProfileLogoutService.shared
    private let gradientAnimation = GradientAnimation.shared
    
    private let gradient = CAGradientLayer()
    private var animationLayers: [CALayer] = []
    var profile: Profile?
    
    override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
        addObserver()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addObserver()
    }
    
    deinit {
        removeObserver()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        
        configurePhotoImageView()
        presenter?.setAvatar()
        profile = presenter?.getProfile()
        guard let profile else {
            return
        }
        
        configureLabels(
            name: profile.name,
            loginName: profile.loginName,
            bio: profile.name)
        configureExitButton()
    }
    // MARK: - Private Function
    private func addObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateAvatar(notification:)),
            name: ProfileImageService.didChangeNotification,
            object: nil)
    }
    
    private func removeObserver() {
        NotificationCenter.default.removeObserver(
            self,
            name: ProfileImageService.didChangeNotification,
            object: nil)
    }
    
    func prepareImage(url: URL) {
        photoImageView.kf.setImage(
            with: url,
            completionHandler: { [weak self] _ in
                guard let self = self else { return }
                self.gradientAnimation.removeFromSuperLayer(views: [self.photoImageView, self.nameLabel, self.nicknameLabel, self.descriptionLabel])
            }
        )
    }
    
    @objc
    private func updateAvatar(notification: Notification) {
        guard isViewLoaded else { return }
        presenter?.updateAvatar(notification: notification)
    }
    
    private func configurePhotoImageView() {
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(photoImageView)
        
        NSLayoutConstraint.activate([
            photoImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            photoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            photoImageView.widthAnchor.constraint(equalToConstant: 70),
            photoImageView.heightAnchor.constraint(equalToConstant: 70),
        ])
        
        gradientAnimation.addGradient(view: photoImageView, width: 70, height: 70, cornerRadius: 35)
    }
    
    private func configureLabels(name: String, loginName: String, bio: String) {
        stackView.spacing = 8
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        navigationItem.titleView = stackView
        
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(nicknameLabel)
        stackView.addArrangedSubview(descriptionLabel)
        
        
        nameLabel.text = name
        nameLabel.textColor = .ypWhite
        nameLabel.font = .boldSystemFont(ofSize: 23)
        nicknameLabel.text = loginName
        nicknameLabel.textColor = .ypGrey
        nicknameLabel.font = .systemFont(ofSize: 13)
        descriptionLabel.text = bio
        descriptionLabel.textColor = .ypWhite
        descriptionLabel.font = .systemFont(ofSize: 13)
        descriptionLabel.numberOfLines = 0
        
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: photoImageView.leadingAnchor),
        ])
        
        gradientAnimation.addGradient(view: nameLabel, width: nameLabel.intrinsicContentSize.width, height: nameLabel.intrinsicContentSize.height, cornerRadius: 13)
        gradientAnimation.addGradient(view: nicknameLabel, width: nicknameLabel.intrinsicContentSize.width, height: nicknameLabel.intrinsicContentSize.height, cornerRadius: 8)
        gradientAnimation.addGradient(view: descriptionLabel, width: descriptionLabel.intrinsicContentSize.width, height: descriptionLabel.intrinsicContentSize.height, cornerRadius: 8)
    }
    
    private func configureExitButton() {
        let exitButton = UIButton.systemButton(
            with: UIImage(systemName: "ipad.and.arrow.forward")!,
            target: self,
            action: #selector(Self.didTapExitButton))
        exitButton.tintColor = .ypRed
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitButton)
        
        exitButton.accessibilityIdentifier = "ProfileExitButton"
        
        NSLayoutConstraint.activate([
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            exitButton.centerYAnchor.constraint(equalTo: photoImageView.centerYAnchor),
        ])
    }
    
    @objc
    func didTapExitButton(_ sender: Any) {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Вы уверенны что хотите выйти?",
            preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.profileLogoutService.logout()
            guard let window = UIApplication.shared.windows.first else {
                assertionFailure("Invalid window configuration")
                return
            }
            let splashVC = SplashViewController()
            window.rootViewController = splashVC
        }
        let noAction = UIAlertAction(title: "Нет", style: .default)
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        present(alert, animated: true)
    }
}
