//
//  EditProfileViewBuilder.swift
//  ShareTodo
//
//  Created by jun on 2020/07/25.
//  Copyright © 2020 jun. All rights reserved.
//

import UIKit

struct EditProfileViewBuilder {
    static func create() -> UIViewController {
        guard let editProfileViewController = EditProfileViewController.loadFromStoryboard() as? EditProfileViewController else {
            fatalError("fatal: Failed to initialize the EditProfileViewController")
        }
        let model = EditProfileModel()
        let presenter = EditProfileViewPresenter(model: model)
        editProfileViewController.inject(with: presenter)
        return editProfileViewController
    }
}
