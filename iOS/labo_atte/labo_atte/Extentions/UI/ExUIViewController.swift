//
//  ExUIViewController.swift
//  ShareTodo
//
//  Created by jun on 2020/07/24.
//  Copyright © 2020 jun. All rights reserved.
//

import UIKit

public extension UIViewController {
    class func loadFromStoryboard<T>() -> T where T: UIViewController {
        let storyboard = UIStoryboard(name: NSStringFromClass(self).components(separatedBy: ".").last!.removeAt(text: "ViewController")!, bundle: nil)
        return storyboard.instantiateInitialViewController() as! T
    }
}
