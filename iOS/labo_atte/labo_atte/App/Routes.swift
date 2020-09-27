//
//  Routes.swift
//  labo_atte
//
//  Created by jun on 2020/09/27.
//

import UIKit
import Firebase

struct Routes {
    static func decideRootViewController() -> UIViewController {
        if Auth.auth().currentUser == nil {
            return RegisterUserViewBuilder.create()
        }
        
        return MainTabBarViewBuilder.create()
    }
}
