//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Andrey Gordienko on 28.01.2024.
//

import UIKit

final class ProfileViewController: UIViewController {
    //MARK: - Private Properties
    private var photoImageView = UIImageView()
    private var nameLabel: UILabel?
    private var nicknameLabel: UILabel?
    private var descriptionLabel: UILabel?
    private var stackView = UIStackView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage(named: "mockProfilePhoto")
        let name = "Екатерина Новикова"
        let nickname = "@ekaterina_nov"
        let description = "Hello, world!"
        
        photoImageViewConfigure(with: image!)
        labelsConfigure(name: name, nickname: nickname, description: description)
        exitButtonConfigure()
    }
// MARK: - Private Function
    private func photoImageViewConfigure(with image: UIImage) {
        photoImageView.image = image
        photoImageView.layer.cornerRadius = 35
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(photoImageView)
        
        NSLayoutConstraint.activate([
            photoImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            photoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            photoImageView.widthAnchor.constraint(equalToConstant: 70),
            photoImageView.heightAnchor.constraint(equalToConstant: 70),
        ])
    }
    
    private func labelsConfigure(name: String, nickname: String, description: String) {
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
        nicknameLabel.text = nickname
        nicknameLabel.textColor = .ypGrey
        nicknameLabel.font = .systemFont(ofSize: 13)
        descriptionLabel.text = description
        descriptionLabel.textColor = .ypWhite
        descriptionLabel.font = .systemFont(ofSize: 13)

        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: photoImageView.leadingAnchor),
        ])
    }
    
    private func exitButtonConfigure() {
        var exitButton = UIButton.systemButton(
            with: UIImage(systemName: "ipad.and.arrow.forward")!,
            target: self,
            action: #selector(Self.didTapExitButton))
        exitButton.tintColor = .red
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