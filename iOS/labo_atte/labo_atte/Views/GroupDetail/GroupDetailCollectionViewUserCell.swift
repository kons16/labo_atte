//
//  GroupDetailCollectionViewUserCell.swift
//  ShareTodo
//
//  Created by jun on 2020/09/06.
//  Copyright © 2020 jun. All rights reserved.
//

import UIKit
import Nuke

class GroupDetailCollectionViewUserCell: UICollectionViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var customImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setupCell()
        self.setupProfileImageView()
        self.setupNameLabel()
        self.setupCustomImageView()
    }
    
    func setupCell() {
        self.backgroundColor = .systemBackground
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
    }
    
    func setupProfileImageView() {
        self.profileImageView.layer.borderWidth = 0.25
        self.profileImageView.layer.borderColor = UIColor.systemGray4.cgColor
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.width / 2
        self.profileImageView.layer.masksToBounds = true
    }
    
    func setupNameLabel() {
        self.nameLabel.adjustsFontSizeToFitWidth = true
        self.nameLabel.minimumScaleFactor = 0.4
    }
    
    func setupCustomImageView() {
        self.customImageView.contentMode = .scaleAspectFill
        self.customImageView.backgroundColor = UIColor.randomSystemColor()
        self.customImageView.layer.cornerRadius = 4
        self.customImageView.layer.masksToBounds = true
    }
    
    func configure(with user: User) {
        self.nameLabel.text = user.name
        
        guard let url = URL(string: user.profileImageURL ?? "") else { return }
        DispatchQueue.main.async {
            let options = ImageLoadingOptions(placeholder: R.image.placeholderImage(), transition: .fadeIn(duration: 0.25), failureImage: R.image.defaultProfileImage())
            loadImage(with: url, options: options, into: self.profileImageView, progress: nil, completion: nil)
        }
    }

}
