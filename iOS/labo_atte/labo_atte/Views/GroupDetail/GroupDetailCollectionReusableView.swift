//
//  GroupDetailCollectionReusableView.swift
//  ShareTodo
//
//  Created by jun on 2020/09/04.
//  Copyright © 2020 jun. All rights reserved.
//

import UIKit

class GroupDetailCollectionReusableView: UICollectionReusableView {
    @IBOutlet weak var sectionTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    func setLabelTitle(title: String) {
        self.sectionTitleLabel.text = title
    }
}
