//
//  SearchUserTableviewCell.swift
//  ShareTodo
//
//  Created by jun on 2020/07/26.
//  Copyright © 2020 jun. All rights reserved.
//

import UIKit
import Nuke

class SearchUserTableviewCell: UITableViewCell {
    @IBOutlet weak var radioImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setupRadioImageView()
        self.setupProfileImageView()
        self.setupUserNameLabel()
    }
    
    private func setupRadioImageView() {
        self.radioImageView.contentMode = .scaleAspectFill
        self.radioImageView.layer.cornerRadius = self.radioImageView.frame.width / 2
        self.radioImageView.layer.masksToBounds = true
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
    
    func configure(with user: User, isSelected: Bool) {
        self.userNameLabel.text = user.name
            
        DispatchQueue.main.async {
            let options = ImageLoadingOptions(placeholder: R.image.placeholderImage(), transition: .fadeIn(duration: 0.25), failureImage: R.image.defaultProfileImage())
            loadImage(with: URL(string: user.profileImageURL ?? "")!, options: options, into: self.profileImageView, progress: nil, completion: nil)
        }
        
        radioImageView.image = isSelected ? UIImage(systemName: "checkmark.seal.fill") : UIImage(systemName: "checkmark.seal")
        radioImageView.tintColor = isSelected ? .systemGreen : .systemGray
    }
}
