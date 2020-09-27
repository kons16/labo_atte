//
//  SelectedUserCollectionViewCell.swift
//  ShareTodo
//
//  Created by jun on 2020/07/26.
//  Copyright © 2020 jun. All rights reserved.
//

import UIKit
import Nuke

class SelectedUserCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var deleteUserButton: UIButton!
    
    
    var deleteUserButtonAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setupProfileImageView()
        self.setupUserNameLabel()
        self.setupDeleteUserButton()
    }
    
    private func setupProfileImageView() {
        self.profileImageView.layer.borderWidth = 0.25
        self.profileImageView.layer.borderColor = UIColor.systemGray4.cgColor
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.width / 2
        self.profileImageView.layer.masksToBounds = true
    }
    
    private func setupUserNameLabel() {
        self.userNameLabel.adjustsFontSizeToFitWidth = true
        self.userNameLabel.minimumScaleFactor = 0.4
    }
    
    private func setupDeleteUserButton() {
        self.deleteUserButton.layer.cornerRadius = self.deleteUserButton.frame.width / 2
        self.deleteUserButton.layer.masksToBounds = true
    }
    
    func configure(with user: User) {
        self.userNameLabel.text = user.name
        
        guard let url = URL(string: user.profileImageURL ?? "") else {
            self.profileImageView.image = R.image.defaultProfileImage()
            return
        }
        
        DispatchQueue.main.async {
            let options = ImageLoadingOptions(placeholder: R.image.placeholderImage(), transition: .fadeIn(duration: 0.25), failureImage: R.image.defaultProfileImage())
            loadImage(with: url, options: options, into: self.profileImageView, progress: nil, completion: nil)
        }
    }
    
    @IBAction func tapDeleteUserButton(_ sender: Any) {
        self.deleteUserButtonAction?()
    }
    
}
