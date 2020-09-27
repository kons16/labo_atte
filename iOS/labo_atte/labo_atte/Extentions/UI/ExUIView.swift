//
//  ExUIView.swift
//  ShareTodo
//
//  Created by jun on 2020/07/24.
//  Copyright © 2020 jun. All rights reserved.
//

import UIKit

public extension UIView {
    class func create<T>() -> T where T: UIView {
        let nib = UINib(nibName: NSStringFromClass(self).components(separatedBy: ".").last!, bundle: nil)
        return nib.instantiate(withOwner: nil, options: nil)[0] as! T
    }
}
