//
//  ExCollectionView.swift
//  ShareTodo
//
//  Created by jun on 2020/07/26.
//  Copyright © 2020 jun. All rights reserved.
//

import UIKit

public extension UICollectionView {
    func addBorderBottom(borderWidth: CGFloat, color: UIColor) {
        let border = CALayer()
        border.frame = CGRect(x: 0, y: self.frame.height - borderWidth, width: self.frame.width, height: borderWidth)
        border.backgroundColor = color.cgColor
        self.layer.addSublayer(border)
    }
    
    func addBorderTop(borderWidth: CGFloat, color: UIColor) {
        let border = CALayer()
        border.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: borderWidth)
        border.backgroundColor = color.cgColor
        self.layer.addSublayer(border)
    }
}
