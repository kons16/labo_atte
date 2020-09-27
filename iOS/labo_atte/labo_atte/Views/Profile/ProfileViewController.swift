//
//  ProfileViewController.swift
//  ShareTodo
//
//  Created by jun on 2020/07/24.
//  Copyright © 2020 jun. All rights reserved.
//

import UIKit
import Nuke

final class ProfileViewController: UIViewController {
    private var presenter: ProfileViewPresenterProtocol!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupScrollView()
        self.setupProfileImageView()
        self.setupNameLabel()
        self.setupNavigationBar()
        self.setupUIBarButtonItem()
        
        self.presenter.didViewDidLoad()
    }
    
    func setupScrollView() {
        self.scrollView.alwaysBounceVertical = true
    }
    
    func setupProfileImageView() {
        self.profileImageView.image = R.image.defaultProfileImage()
        self.profileImageView.layer.borderWidth = 0.25
        self.profileImageView.layer.borderColor = UIColor.systemGray4.cgColor
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.width / 2
        self.profileImageView.layer.masksToBounds = true
    }
    
    func setupNameLabel() {
        self.nameLabel.adjustsFontSizeToFitWidth = true
        self.nameLabel.minimumScaleFactor = 0.4
    }
    
    func setupNavigationBar() {
        self.navigationItem.title = "Me"
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func setupUIBarButtonItem() {
        let editProfileButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editProfile(_:)))
        editProfileButtonItem.tintColor = .systemGreen
        self.navigationItem.rightBarButtonItem = editProfileButtonItem
        self.navigationItem.rightBarButtonItem?.tintColor = .systemGreen
        self.navigationItem.rightBarButtonItem?.isEnabled = false
    }

    @objc func editProfile(_ sender: UIButton) {
        self.presenter.didTapEditProfileButton()
    }
    
    func inject(with presenter: ProfileViewPresenterProtocol) {
        self.presenter = presenter
        self.presenter.view = self
    }
}

extension ProfileViewController: ProfileViewPresenterOutput {
    func presentEditProfileVC() {
        guard let editProfileVC = EditProfileViewBuilder.create() as? EditProfileViewController else { return }
        editProfileVC.profileImage = self.profileImageView.image ?? UIImage()
        editProfileVC.userName = self.nameLabel.text
        
        let navigationController = UINavigationController(rootViewController: editProfileVC)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func setUserName(userName: String) {
        self.nameLabel.text = userName
    }
    
    func setProfileImage(URL: URL) {
        DispatchQueue.main.async {
            let options = ImageLoadingOptions(placeholder: R.image.placeholderImage(), transition: .fadeIn(duration: 0.25), failureImage: R.image.defaultProfileImage())
            loadImage(with: URL, options: options, into: self.profileImageView, progress: nil, completion: { _ in
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            })
        }
    }
}
