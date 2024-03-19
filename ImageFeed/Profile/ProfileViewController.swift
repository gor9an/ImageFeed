//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Andrey Gordienko on 28.01.2024.
//

import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    //MARK: - Private Properties
    private var photoImageView = UIImageView()
    private var nameLabel: UILabel?
    private var nicknameLabel: UILabel?
    private var descriptionLabel: UILabel?
    private var stackView = UIStackView()
    private let profileService = ProfileService.shared
    private let profileImage = ProfileImageService.shared
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
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
        
        guard let profile = profileService.profile else {
            return
        }
        
        if let avatarURL = ProfileImageService.shared.avatarURL,
           let url = URL(string: avatarURL) {
            
            prepareImage(url: url)
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
    
    private func prepareImage(url: URL) {
        let processor = RoundCornerImageProcessor(cornerRadius: 70)
        
        photoImageView.kf.indicatorType = .activity
        photoImageView.kf.setImage(with: url,
                                   placeholder: UIImage(named: "tab_profile_active.png"),
                                   options: [.processor(processor)])
    }
    
    @objc
    private func updateAvatar(notification: Notification) {
        guard
            isViewLoaded,
            let userInfo = notification.userInfo,
            let profileImageURL = userInfo["URL"] as? String,
            let url = URL(string: profileImageURL) else { return }
        
        prepareImage(url: url)
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
    }
    
    private func configureLabels(name: String, loginName: String, bio: String) {
        nameLabel = UILabel()
        nicknameLabel = UILabel()
        descriptionLabel = UILabel()
        guard let nameLabel = nameLabel else { return }
        guard let nicknameLabel = nicknameLabel else { return }
        guard let descriptionLabel = descriptionLabel else { return }
        
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
    }
    
    private func configureExitButton() {
        let exitButton = UIButton.systemButton(
            with: UIImage(systemName: "ipad.and.arrow.forward")!,
            target: self,
            action: #selector(Self.didTapExitButton))
        exitButton.tintColor = .ypRed
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitButton)
        
        NSLayoutConstraint.activate([
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            exitButton.centerYAnchor.constraint(equalTo: photoImageView.centerYAnchor),
        ])
    }
    
    @IBAction func didTapExitButton(_ sender: Any) {
        nameLabel?.removeFromSuperview()
        nicknameLabel?.removeFromSuperview()
        descriptionLabel?.removeFromSuperview()
        nameLabel = nil
        nicknameLabel = nil
        descriptionLabel = nil
        photoImageView.image = UIImage(systemName: "person.crop.circle.fill")
        photoImageView.tintColor = .gray
    }
}
