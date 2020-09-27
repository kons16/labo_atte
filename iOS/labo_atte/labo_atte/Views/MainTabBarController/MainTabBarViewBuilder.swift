//
//  MainTabBarViewBuilder.swift
//  labo_atte
//
//  Created by jun on 2020/09/27.
//

import UIKit

struct MainTabBarViewBuilder {
    static func create() -> UIViewController {
        guard let mainTabBarViewController = MainTabBarViewController.loadFromStoryboard() as? MainTabBarViewController else {
            fatalError("fatal: Failed to initialize the MainTabBarViewController")
        }
        let model = MainTabBarModel()
        let presenter = MainTabBarViewPresenter(model: model)
        mainTabBarViewController.inject(with: presenter)
        return mainTabBarViewController
    }
}
