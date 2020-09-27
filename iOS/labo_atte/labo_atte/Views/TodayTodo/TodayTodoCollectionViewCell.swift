//
//  TodayTodoCollectionViewCell.swift
//  ShareTodo
//
//  Created by jun on 2020/07/24.
//  Copyright © 2020 jun. All rights reserved.
//

import UIKit
import Nuke

class TodayTodoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var radioButton: UIButton!
    
    
    
    var radioButtonAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .systemBackground
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        
        self.setupGroupImageView()
        self.setupTaskLabel()
        self.setupRadioButton()
    }
    
    func setupGroupImageView() {
        self.groupImageView.layer.borderWidth = 0.25
        self.groupImageView.layer.borderColor = UIColor.systemGray4.cgColor
        self.groupImageView.layer.cornerRadius = self.groupImageView.frame.width / 2
        self.groupImageView.layer.masksToBounds = true
    }
    
    func setupTaskLabel() {
        self.taskLabel.adjustsFontSizeToFitWidth = true
        self.taskLabel.minimumScaleFactor = 0.4
    }
    
    func setupRadioButton() {
        self.radioButton.layer.cornerRadius = self.groupImageView.frame.width / 2
        self.radioButton.layer.masksToBounds = true
        self.radioButton.tintColor = .systemGreen
    }
    
    func configure(with group: Group, isFinished: Bool) {
        let radioButtonImage = isFinished ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "checkmark.circle")
        
        self.taskLabel.text = group.task
        //TODO:- StringFileで抜き出すこと
        self.groupNameLabel.text = "Group: " + group.name
        self.radioButton.setImage(radioButtonImage, for: .normal)
        
        guard let url = URL(string: group.profileImageURL ?? "") else { return }
        DispatchQueue.main.async {
//            let options = ImageLoadingOptions(placeholder: R.image.placeholderImage(), transition: .fadeIn(duration: 0.25), failureImage: R.image.groupDefaultImage())
//            loadImage(with: url, options: options, into: self.groupImageView, progress: nil, completion: nil)
        }
    }
    @IBAction func tapRadioButton(_ sender: Any) {
        self.radioButtonAction?()
    }
    
}
