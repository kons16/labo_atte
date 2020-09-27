//
//  ProfileViewBuilder.swift
//  ShareTodo
//
//  Created by jun on 2020/07/24.
//  Copyright © 2020 jun. All rights reserved.
//

import UIKit

struct ProfileViewBuilder {
    static func create() -> UIViewController {
        guard let profileViewController = ProfileViewController.loadFromStoryboard() as? ProfileViewController else {
            fatalError("fatal: Failed to initialize the ProfileViewController")
        }
        let model = ProfileModel()
        let presenter = ProfileViewPresenter(model: model)
        profileViewController.inject(with: presenter)
        return profileViewController
    }
}
